const express = require("express");
const student_Act = require("../controllers/students");
const router = express.Router();

router.get('/', student_Act.getStudents);
router.get('/:roll', student_Act.getSpecStudent);
router.post('/', student_Act.createStudent);
router.patch('/:roll', student_Act.updateStudent);
router.delete('/:roll', student_Act.deleteStudent);

module.exports = router;