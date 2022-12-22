const fs = require('fs');
const contents = fs.readFileSync(process.argv[2], 'utf-8');

p1 = 0
p2 = 0

contents.split(/\r?\n/).forEach(line =>  {
  if ( line != '' ) {
    limits = line.replaceAll('-', ',').split(',').map(x => parseInt(x))
    p1 += (limits[0] >= limits[2] && limits[1] <= limits[3]) || (limits[2] >= limits[0] && limits[3] <= limits[1])
    p2 += (limits[0] >= limits[2] && limits[0] <= limits[3]) || (limits[2] >= limits[0] && limits[2] <= limits[1])
  }
});

console.log(p1, p2)
