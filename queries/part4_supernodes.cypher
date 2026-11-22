// Find nodes with the most connections
MATCH (n)
WITH n, COUNT { (n)--() } AS connections
RETURN labels(n) AS nodeType,
       coalesce(n.title, n.name, toString(n.userId)) AS node,
       connections
ORDER BY connections DESC
LIMIT 10;

// Find genres connected to the most movies
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)
RETURN g.name AS genre,
       count(m) AS moviesConnected
ORDER BY moviesConnected DESC
LIMIT 10;
