//Adding the Director Label

MATCH (p:Person)
WHERE exists ((p)-[:DIRECTED]-())
SET p:Director

//Adding Language nodes

MATCH (n) DETACH DELETE n;
MERGE (apollo:Movie {title: 'Apollo 13', tmdbId: 568, released: '1995-06-30', imdbRating: 7.6, genres: ['Drama', 'Adventure', 'IMAX']})
MERGE (tom:Person {name: 'Tom Hanks', tmdbId: 31, born: '1956-07-09'})
MERGE (meg:Person {name: 'Meg Ryan', tmdbId: 5344, born: '1961-11-19'})
MERGE (danny:Person {name: 'Danny DeVito', tmdbId: 518, born: '1944-11-17'})
MERGE (sleep:Movie {title: 'Sleepless in Seattle', tmdbId: 858, released: '1993-06-25', imdbRating: 6.8, genres: ['Comedy', 'Drama', 'Romance']})
MERGE (hoffa:Movie {title: 'Hoffa', tmdbId: 10410, released: '1992-12-25', imdbRating: 6.6, genres: ['Crime', 'Drama']})
MERGE (jack:Person {name: 'Jack Nicholson', tmdbId: 514, born: '1937-04-22'})
MERGE (sandy:User {name: 'Sandy Jones', userId: 534})
MERGE (clinton:User {name: 'Clinton Spencer', userId: 105})
MERGE (tom)-[:ACTED_IN {role: 'Jim Lovell'}]->(apollo)
MERGE (tom)-[:ACTED_IN {role: 'Sam Baldwin'}]->(sleep)
MERGE (meg)-[:ACTED_IN {role: 'Annie Reed'}]->(sleep)
MERGE (danny)-[:ACTED_IN {role: 'Bobby Ciaro'}]->(hoffa)
MERGE (danny)-[:DIRECTED]->(hoffa)
MERGE (jack)-[:ACTED_IN {role: 'Jimmy Hoffa'}]->(hoffa)
MERGE (sandy)-[:RATED {rating:5}]->(apollo)
MERGE (sandy)-[:RATED {rating:4}]->(sleep)
MERGE (clinton)-[:RATED {rating:3}]->(apollo)
MERGE (clinton)-[:RATED {rating:3}]->(sleep)
MERGE (clinton )-[:RATED {rating:3}]->(hoffa)
MERGE (casino:Movie {title: 'Casino', tmdbId: 524, released: '1995-11-22', imdbRating: 8.2, genres: ['Drama','Crime']})
MERGE (martin:Person {name: 'Martin Scorsese', tmdbId: 1032})
MERGE (martin)-[:DIRECTED]->(casino)
SET tom:Actor
SET meg:Actor
SET danny:Actor
SET jack:Actor
SET danny:Director
SET martin:Director
SET apollo.languages = ['English']
SET sleep.languages =  ['English']
SET hoffa.languages =  ['English', 'Italian', 'Latin']
SET casino.languages =  ['English'];

MATCH (m:Movie)
UNWIND m.languages AS language
WITH  language, collect(m) AS movies
MERGE (l:Language {name:language})
WITH l, movies
UNWIND movies AS m
WITH l,m
MERGE (m)-[:IN_LANGUAGE]->(l);
MATCH (m:Movie)
SET m.languages = null

//Adding Genre nodes

MATCH (m:Movie)
UNWIND m.genres AS genre
MERGE (g:Genre {name: genre})
MERGE (m)-[:IN_GENRE]->(g)
SET m.genres = null

//Specializing ACTED_IN and DIRECTED Relationships
MATCH (n:Actor)-[:ACTED_IN]->(m:Movie)
CALL apoc.merge.relationship(n,
  'ACTED_IN_' + left(m.released,4),
  {},
  {},
  m ,
  {}
) YIELD rel
RETURN count(*) AS `Number of relationships merged`;

MATCH (n:Director)-[r:DIRECTED]->(m:Movie)
CALL apoc.merge.relationship(n,
  'DIRECTED_' + left(m.released,4),
  {},
  {},
  m,
  {}
) YIELD rel
RETURN COUNT(*) AS `Number of relationships added`;

//Specializing RATED Relationships
MATCH (n:User)-[r:RATED]->(m:Movie)
CALL apoc.merge.relationship(n,
  'RATED_' + r.rating,
  {},
  {},
  m,
  {}
) YIELD rel
RETURN COUNT(*) AS `Number of relationships added`;

//Adding a Role Node
// Find an actor that acted in a Movie
MATCH (a:Actor)-[r:ACTED_IN]->(m:Movie)

// Create a Role node
MERGE (x:Role {name: r.role})

// Create the PLAYED relationship
// relationship between the Actor and the Role nodes.
MERGE (a)-[:PLAYED]->(x)

// Create the IN_MOVIE relationship between
// the Role and the Movie nodes.
MERGE (x)-[:IN_MOVIE]->(m)
