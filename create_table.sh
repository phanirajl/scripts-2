# create keyspace and table
cqlsh -u cassandra -p cassandra << EOF
DROP KEYSPACE IF EXISTS ks1;

CREATE KEYSPACE ks1 WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1 };
CREATE TABLE ks1.tab1 (
  key_part1 int,
  key_part2 int,
  clust_part1 int,
  data text,
  PRIMARY KEY ((key_part1, key_part2), clust_part1 )
) WITH CLUSTERING ORDER BY (clust_part1 ASC);

EOF

# Create load file and load in the data
cat /dev/null > loadfile.cql
for ((i=1000; i<=1100; i++)); do 
  for ((j=1; j<=10; j++)); do 
    for ((k=1; k<=10; k++)); do 
      printf "insert into ks1.tab1 (key_part1, key_part2, clust_part1, data) values ($i, $j, $k, 'test row');\n" \
        >> loadfile.cql
    done
  done
done

cqlsh -u cassandra -p cassandra -f loadfile.cql

# Trace
cqlsh -u cassandra -p cassandra -e "TRACING ON; SELECT * FROM ks1.tab1 LIMIT 10; TRACING OFF;" | tee results_limit_10.txt

cqlsh -u cassandra -p cassandra -e "TRACING ON; SELECT * FROM ks1.tab1 LIMIT 1000 ; TRACING OFF;" \
  | tee results_limit_1000.txt


