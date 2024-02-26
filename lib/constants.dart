const appName = 'Pencil Game Admin Console';

const appBarHeight = 60.0;
const cardMaxWidth = 500.0;

// for calculating schedule
const maxTriesFromStart = 100;
const maxRoundTries = 250;

// database collection and field names
const adminsCollectionName = 'admins';
const experimentCollectionName = 'experiments';
const adminShareCodeCollectionName = 'adminShareCodes';
const userShareCodeCollectionName = 'userShareCodes';
const tableCollectionName = 'tables';
const userCollectionName = 'users';
const scheduleCollectionName = 'schedule';
const scheduleDocName = 'schedule';

const adminUidFieldName = 'adminUid';
const sharedAdminListName = 'sharedWithAdminUids';
const experimentsListName = 'experiments';
const experimentIDName = 'experimentID';
const shareCodeName = 'shareCode';

const shareCodesValidDuration = Duration(minutes: 60);
