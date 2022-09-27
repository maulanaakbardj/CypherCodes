// Transform String Properties

MATCH (p:Person)
SET p.born = CASE p.born WHEN "" THEN null ELSE date(p.born) END
WITH p
SET p.died = CASE p.died WHEN "" THEN null ELSE date(p.died) END

//Transform Strings to Lists
MATCH (m:Movie)
SET m.countries = split(coalesce(m.countries,""), "|"),
m.languages = split(coalesce(m.languages,""), "|"),
m.genres = split(coalesce(m.genres,""), "|")

// Add labels to graphs

// add the actor labels
MATCH (p:Person)-[:ACTED_IN]->()
WITH DISTINCT p SET p:Actor

// add the directorlabels
MATCH (p:Person)-[:DIRECTED]->()
WITH DISTINCT p SET p:Director


// Create genre nodes 

CREATE CONSTRAINT Genre_name ON (g:Genre) ASSERT g.name IS UNIQUE

MATCH (m:Movie)
UNWIND m.genres AS genre
WITH m, genre
MERGE (g:Genre {name:genre})
MERGE (m)-[:IN_GENRE]->(g)
