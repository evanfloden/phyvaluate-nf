# data/fasttree_aa/5000/COG1309/model/ true.tt true.fa true.fasta

files="../data/fasttree_aa/5000/COG*/model/true.*"

regex="(COG[0-9]+)/model/true.([a-z]+)"
for f in $files
do
    [[ $f =~ $regex ]]
    id="${BASH_REMATCH[1]}"
    extension="${BASH_REMATCH[2]}"
    echo $f "id = $id ext = $extension"
    cp $f "../data/rose_AA/$id.$extension"
done

