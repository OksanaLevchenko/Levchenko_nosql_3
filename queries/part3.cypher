// Query 1 - Thriller movies with average rating above 4
MATCH (m:Movie)-[:HAS_GENRE]->(:Genre {name: 'Thriller'})
MATCH (:User)-[r:RATED]->(m)
WITH m, avg(r.rating) AS avgRating, count(r) AS totalRatings
WHERE avgRating > 4.0
RETURN m.title AS movie, round(avgRating, 2) AS averageRating, totalRatings
ORDER BY averageRating DESC
LIMIT 10;

// Query 2 - Users who gave more than 50 ratings of 5
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE r.rating = 5
WITH u, count(m) AS fiveStarMovies
WHERE fiveStarMovies > 50
RETURN u.userId AS userId, fiveStarMovies
ORDER BY fiveStarMovies DESC
LIMIT 10;

// Query 3 - Movies rated highly by users 1 and 2
MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)
MATCH (u2:User {userId: 2})-[r2:RATED]->(m)
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.title AS movie,
       r1.rating AS user1Rating,
       r2.rating AS user2Rating
ORDER BY m.title
LIMIT 10;

// Query 4 - Average rating by genre
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-(:User)
WITH g, avg(r.rating) AS avgRating, count(r) AS totalRatings
RETURN g.name AS genre, round(avgRating, 2) AS averageRating, totalRatings
ORDER BY averageRating DESC;

// Query 5 - Movie recommendations for user 1
MATCH (u:User {userId: 1})-[r1:RATED]->(liked:Movie)
WHERE r1.rating >= 4
MATCH (similar:User)-[r2:RATED]->(liked)
WHERE similar <> u AND r2.rating >= 4
WITH u, similar, count(DISTINCT liked) AS commonMovies
WHERE commonMovies >= 3
MATCH (similar)-[r3:RATED]->(recommended:Movie)
WHERE r3.rating >= 4
  AND NOT EXISTS {
    MATCH (u)-[:RATED]->(recommended)
  }
RETURN recommended.title AS movie,
       count(DISTINCT similar) AS recommendedBy,
       round(avg(r3.rating), 2) AS averageRating
ORDER BY recommendedBy DESC, averageRating DESC
LIMIT 10;

// Query 6 - Shortest path between users 1 and 2
MATCH (u1:User {userId: 1})
MATCH (u2:User {userId: 2})
MATCH p = shortestPath((u1)-[:RATED*..6]-(u2))
RETURN [n IN nodes(p) |
    CASE
        WHEN n:User THEN 'User ' + toString(n.userId)
        ELSE n.title
    END
] AS path,
length(p) AS steps;
