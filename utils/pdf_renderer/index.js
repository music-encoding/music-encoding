const Prince = require("prince")
const util   = require("util")

const workDir = '../../source'
const inPath = 'MEI_Guidelines.html'
const outPath = 'MEI_Guidelines.html'

Prince()
   .cwd(workDir)
   .inputs(inPath)
   .output(outPath)
   .execute()
   .then(function () {
     console.log("OK: done")
   }, function (error) {
     console.log("ERROR: ", util.inspect(error))
     console.log('\n')
     console.log(typeof error)
   })
