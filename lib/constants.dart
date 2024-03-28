const appName = 'Pencil Game Admin Console';

const appBarHeight = 60.0;
const cardMaxWidth = 500.0;

// for calculating schedule
const maxTriesFromStart = 100;
const maxRoundTries = 250;

// game related constants
const startTimeInSeconds = 6;
const gameTimeInSeconds = 10; // TODO: 120 sec

// database collection and field names
const adminsCollectionName = 'admins';
const experimentCollectionName = 'experiments';
const adminShareCodeCollectionName = 'adminShareCodes';
const userShareCodeCollectionName = 'userShareCodes';
const tableCollectionName = 'tables';
const userCollectionName = 'users';
const settingsCollectionName = 'settings';
const scheduleDocName = 'schedule';
const parameterDocName = 'parameters';
const progressDocName = 'progress';

const adminUidFieldName = 'adminUid';
const sharedAdminListName = 'sharedWithAdminUids';
const experimentsListName = 'experiments';
const experimentIDName = 'experimentID';
const shareCodeName = 'shareCode';

const shareCodesValidDuration = Duration(minutes: 60);
