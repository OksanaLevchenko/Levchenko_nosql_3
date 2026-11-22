// Create indexes
CREATE INDEX user_id IF NOT EXISTS
FOR (u:User) ON (u.userId);

CREATE INDEX movie_id IF NOT EXISTS
FOR (m:Movie) ON (m.movieId);

CREATE INDEX genre_name IF NOT EXISTS
FOR (g:Genre) ON (g.name);

// Load users
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {userId: toInteger(row.userId)})
SET u.gender = row.gender,
    u.age = toInteger(row.age),
    u.occupation = toInteger(row.occupation);

// Load movies
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET m.title = row.title,
    m.year = toInteger(
        substring(row.title, size(row.title) - 5, 4)
    );

// Load genres
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MATCH (m:Movie {movieId: toInteger(row.movieId)})
UNWIND split(row.genres, '|') AS genreName
MERGE (g:Genre {name: genreName})
MERGE (m)-[:HAS_GENRE]->(g);

// Load ratings in batches
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row RETURN row",
  "
  MATCH (u:User {userId: toInteger(row.userId)})
  MATCH (m:Movie {movieId: toInteger(row.movieId)})
  MERGE (u)-[r:RATED]->(m)
  SET r.rating = toInteger(row.rating),
      r.timestamp = toInteger(row.timestamp)
  ",
  {batchSize: 1000, parallel: false}
)
YIELD batches, total, failedBatches, errorMessages
RETURN batches, total, failedBatches, errorMessages;
