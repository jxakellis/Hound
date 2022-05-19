const express = require('express');

const router = express.Router({ mergeParams: true });

const {
  getFamily, createFamily, updateFamily, deleteFamily,
} = require('../controllers/main/family');

const { validateFamilyId } = require('../main/tools/format/validateId');

router.param('familyId', validateFamilyId);

// route to dogs (or nested) related things
const dogsRouter = require('./dogs');

router.use('/:familyId/dogs', dogsRouter);

// gets family with userId then return information from families and familyMembers table
router.get('/', getFamily);
// no body

// gets family with familyId then return information from families and familyMembers table
router.get('/:familyId', getFamily);
// no body

// creates family
router.post('/', createFamily);
/* BODY:
*/

// lets a user join a new family
router.put('/', updateFamily);

// updates family
router.put('/:familyId', updateFamily);
/* BODY:
*/

// deletes family
router.delete('/:familyId', deleteFamily);
// no body

module.exports = router;
