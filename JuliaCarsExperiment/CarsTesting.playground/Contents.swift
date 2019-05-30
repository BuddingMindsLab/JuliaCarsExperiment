import UIKit

let a = "a,b,c,d,e\nf,g,h,j,k"
let s = a.components(separatedBy: "\n")
print(s)
var fin = [[String]]()
for i in s {
    fin.append(i.components(separatedBy: ","))
}
print(fin)
