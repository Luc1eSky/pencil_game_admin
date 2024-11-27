// v1 needed for runWith()
// make sure that package.json specifies the latest V1 version
// such as "firebase-functions": "^3.14.1", NOT "firebase-functions": "^6.1.0"
// also requires the matching "firebase-admin": "^11.0.0", NOT "firebase-admin": "^12.7.0",
import * as admin from "firebase-admin"
import * as logger from "firebase-functions/logger"
import * as functions from "firebase-functions"

admin.initializeApp()

// close a specific game (table in experiment) after a certain time
// timeout value is only if function cannot be started
// the specific delay value is given to the function as a parameter
export const delayedClosingGame = functions.runWith({ timeoutSeconds: 200 }).https.onCall(
  async (data: any, context: functions.https.CallableContext)=> {
    // Extract parameters from the data object
    const experimentDocId = data.experimentDocId
    const tableNumber = data.tableNumber
    const waitTimeInSeconds = data.waitTimeInSeconds

    // Handle errors if parameters are missing
    if (experimentDocId === undefined || tableNumber === undefined || waitTimeInSeconds === undefined) {
      const errorString = `A Parameter was undefined. experimentDocId: ${experimentDocId}, 
      tableNumber: ${tableNumber}, waitTimeInSeconds: ${waitTimeInSeconds}`
      logger.error(`Error: ${errorString}`)
      return {"error": errorString}
    }

    try {
      // wait until experiment at table is over
      setTimeout(async ()=> {
        // set table status to "finished"
        await admin.database().ref(`${experimentDocId}/tables/table${tableNumber}`).child("status").set("finished")
        logger.log(`Experiment ${experimentDocId}: Game at table ${tableNumber} was closed.`)
      }, waitTimeInSeconds * 1000) // Convert seconds to milliseconds for setTimeout
      return {"result": "SUCCESS"}
    } catch (error) {
      logger.error("Error updating Realtime Database:", error)
      return {"error": "Failed to update Realtime Database"}
    }
  })


// set current round to status "roundFinished" if all tables have been finished
// gets triggered every time any table status gets updated in the realtime database
export const checkIfRoundWasFinished = functions.database.ref("{experimentDocId}/tables/{table}/status")
  .onUpdate(async (change, context)=> {
    // get experimentDocId and tableNumber
    const experimentDocId = context.params.experimentDocId
    const table = context.params.table

    // get the updated value
    const newValue = change.after.val()
    // exit if the status was NOT changed to finished
    if (newValue !== "finished") {
      logger.log("status was not finished...exit")
      return {"info": "status was not finished...exit"}
    }
    // if the status WAS changed to finished, check if all tables are done
    logger.log(`${table} of experiment ${experimentDocId} was finished. Check if all other tables are finished.`)
    // get tables node reference ("collection")
    const tablesRef = change.after.ref.parent?.parent
    logger.log(`tablesRef: ${tablesRef}`)

    // if tables ref exists
    if (!tablesRef) {
      logger.error("Tables reference does not exist.")
      return {"error": "Tables reference does not exist."}
    } else {
      try {
        // get a snapshot of all tables
        const snapshot = await tablesRef.once("value");
        const tables = snapshot.val();
        if (tables) {
          // go through all children in node (all tables in "collection")
          for (const tableNumber of Object.keys(tables)) {
            const tableData = tables[tableNumber]
            const tableStatus = tableData["status"]

            // exit if a table was not finished yet
            if (tableStatus !== "finished") {
              logger.log(`${tableNumber} had status: ${tableStatus}`)
              return {"info": "not all tables are finished yet"}
            }
          }
        }
      } catch (error) {
        logger.error(`Error fetching tables: ${error}`)
        return {"error": "Error fetching tables"}
      }

      // all tables are finished
      try {
        // set current progress to roundFinished
        const firestore = admin.firestore()
        const progressDocRef = firestore.doc(`experiments/${experimentDocId}/settings/progress`)
        progressDocRef.get().then((progressDocSnap) => {
          // exit if progress document does not exist
          if (!progressDocSnap.exists) {
            logger.error("Progress document does not exist.")
            return {"error": "Progress document does not exist"}
          }
          // read data from document
          const progressData = progressDocSnap.data();
          // exit if progress data does not exist
          if (progressData === undefined) {
            logger.error("Progress data does not exist.")
            return {"error": "Progress data does not exist"}
          }
          // get fields from progress document
          const currentRoundNumber = progressData.currentRoundNumber;
          const maximumRoundNumber = progressData.maximumRoundNumber;

          // exit if any fields do not exist
          if (currentRoundNumber === undefined || maximumRoundNumber === undefined) {
            logger.error(`Could not find progress fields. currentRoundNumber: ${currentRoundNumber},
            maximumRoundNumber: ${maximumRoundNumber}`)
            return {"error": "Could not find progress fields."}
          }
          // update status based on the progress to either "roundFinished" or "experimentFinished"
          if (currentRoundNumber < maximumRoundNumber) {
            progressDocRef.update({"status": "roundFinished"})
            logger.log("round was finished")
            return {"info": "round was finished"}
          } else {
            progressDocRef.update({"status": "experimentFinished"})
            logger.log("experiment was finished")
            return {"info": "experiment was finished"}
          }
        })
      } catch (error) {
        logger.error(`Error updating progress status: ${error}`)
        return {"error": "Error updating progress status"}
      }
    }
    // should never reach this path
    return
  })
