module Dibujo (figura, encimar, apilar,
          juntar, rot45, rotar, espejar,
          modDim, rotAlpha, foldDib, mapDib,
          cuarteto, encimar4, r270, Dibujo(..)
        ) where

--nuestro lenguaje 
data Dibujo a = Figura a 
            | Rotar (Dibujo a)
            | Espejar (Dibujo a)
            | Rot45 (Dibujo a)
            | Apilar Float Float (Dibujo a) (Dibujo a)
            | Juntar Float Float (Dibujo a) (Dibujo a)
            | Encimar (Dibujo a) (Dibujo a)
            | ModDim Float (Dibujo a)
            | RotarAlpha Float (Dibujo a)
           deriving(Show, Eq)

-- combinadores
infixr 6 ^^^

infixr 7 .-.

infixr 8 ///

comp :: Int -> (a -> a) -> a -> a
comp 0 _ d = d
comp n f d = comp (n-1) f (f(d))

-- Funciones constructoras
figura :: a -> Dibujo a
figura a = Figura a

encimar :: Dibujo a -> Dibujo a -> Dibujo a
encimar d1 d2 = Encimar d1 d2

apilar :: Float -> Float -> Dibujo a -> Dibujo a -> Dibujo a
apilar n m d1 d2 = Apilar n m d1 d2

juntar  :: Float -> Float -> Dibujo a -> Dibujo a -> Dibujo a
juntar n m d1 d2 = Juntar n m d1 d2

rot45 :: Dibujo a -> Dibujo a
rot45 d = Rot45 d

rotar :: Dibujo a -> Dibujo a
rotar d = Rotar d

espejar :: Dibujo a -> Dibujo a
espejar d = Espejar d

--Otras transformaciones

modDim :: Float -> Dibujo a -> Dibujo a
modDim m d = ModDim m d

rotAlpha :: Float -> Dibujo a -> Dibujo a
rotAlpha m d = RotarAlpha m d

-- Superpone un dibujo con otro.
(^^^) :: Dibujo a -> Dibujo a -> Dibujo a
(^^^) d1 d2 = encimar d1 d2

-- Pone el primer dibujo arriba del segundo, ambos ocupan el mismo espacio.
(.-.) :: Dibujo a -> Dibujo a -> Dibujo a
(.-.) d1 d2 = apilar 1 1 d1 d2

-- Pone un dibujo al lado del otro, ambos ocupan el mismo espacio.
(///) :: Dibujo a -> Dibujo a -> Dibujo a
(///) d1 d2 = juntar 1 1 d1 d2

-- rotaciones
r90 :: Dibujo a -> Dibujo a
r90 d = rotar d --entiendo q rotar es rot90

r180 :: Dibujo a -> Dibujo a
r180 d = comp 2 r90 d

r270 :: Dibujo a -> Dibujo a
r270 d = comp 3 r90 d

-- una figura repetida con las cuatro rotaciones, superimpuestas.
encimar4 :: Dibujo a -> Dibujo a
encimar4 d = (^^^)((^^^) d (r90 d)) ((^^^)(r180 d) (r270 d))

-- cuatro figuras en un cuadrante.
cuarteto :: Dibujo a -> Dibujo a -> Dibujo a -> Dibujo a -> Dibujo a
cuarteto d1 d2 d3 d4 = (.-.) ((///) d1 d2) ((///) d3 d4)

-- un cuarteto donde se repite la imagen, rotada (¡No confundir con encimar4!)
ciclar :: Dibujo a -> Dibujo a
ciclar d = (.-.) ((///) d (r90 d)) ((///) (r180 d) (r270 d))

-- map para nuestro lenguaje
mapDib :: (a -> b) -> Dibujo a -> Dibujo b
mapDib f (Figura d) = Figura (f d)
mapDib f (Rotar d) = Rotar (mapDib f d)
mapDib f (Espejar d) = Espejar (mapDib f d)
mapDib f (Rot45 d) = Rot45 (mapDib f d)
mapDib f (Apilar m n d1 d2) = Apilar m n (mapDib f d1) (mapDib f d2)
mapDib f (Juntar m n d1 d2) = Juntar m n (mapDib f d1) (mapDib f d2)
mapDib f (Encimar d1 d2) = Encimar (mapDib f d1)(mapDib f d2)
mapDib f (ModDim m d) = ModDim m (mapDib f d)
mapDib f (RotarAlpha m d) = RotarAlpha m (mapDib f d)

-- Cambiar todas las básicas de acuerdo a la función.
change :: (a -> Dibujo b) -> Dibujo a -> Dibujo b
change f (Figura d) = (f d)
change f (Rotar d) = Rotar (change f d)
change f (Espejar d) = Espejar (change f d)
change f (Rot45 d) = Rot45 (change f d)
change f (Apilar m n d1 d2) = Apilar m n (change f d1) (change f d2)
change f (Juntar m n d1 d2) = Juntar m n (change f d1) (change f d2)
change f (Encimar d1 d2) = Encimar (change f d1)(change f d2)
change f (ModDim m d) = ModDim m (change f d)
change f (RotarAlpha m d) = RotarAlpha m (change f d)

-- Principio de recursión para Dibujos.
-- Estructura general para la semántica (a no asustarse). Ayuda: 
-- pensar en foldr y las definiciones de intro a la lógica
-- foldDib aplicado a cada constructor de Dibujo debería devolver el mismo
-- dibujo
foldDib ::
  (a -> b) -> (b -> b) -> (b -> b) -> (b -> b) ->
  (Float -> Float -> b -> b -> b) ->
  (Float -> Float -> b -> b -> b) ->
  (b -> b -> b) ->
  (Float -> b -> b) ->
  (Float -> b -> b) ->
  Dibujo a -> b
foldDib fb _ _ _ _ _ _ _ _ (Figura d) = fb d
foldDib fb ro90 es r45 ap j en md ra (Rotar d) = ro90 (foldDib fb ro90 es r45
                                                        ap j en md ra d)
foldDib fb ro90 es r45 ap j en md ra (Espejar d) = es (foldDib fb ro90 es r45
                                                        ap j en md ra d)
foldDib fb ro90 es r45 ap j en md ra (Rot45 d) = r45 (foldDib fb ro90 es r45
                                                        ap j en md ra d)
foldDib fb ro90 es r45 ap j en md ra (Apilar m n d1 d2) = ap m n
                                      (foldDib fb ro90 es r45 ap j en md ra d1)
                                      (foldDib fb ro90 es r45 ap j en md ra d2)
foldDib fb ro90 es r45 ap j en md ra (Juntar m n d1 d2) = j m n 
                                      (foldDib fb ro90 es r45 ap j en md ra d1)
                                      (foldDib fb ro90 es r45 ap j en md ra d2)
foldDib fb ro90 es r45 ap j en md ra (Encimar d1 d2) = en 
                                      (foldDib fb ro90 es r45 ap j en md ra d1)
                                      (foldDib fb ro90 es r45 ap j en md ra d2)
foldDib fb ro90 es r45 ap j en md ra (ModDim m d) = md m (foldDib fb ro90 es
                                                          r45 ap j en md ra d)
foldDib fb ro90 es r45 ap j en md ra (RotarAlpha m d) = ra m (foldDib fb ro90
                                                        es r45 ap j en md ra d)

{-
donde:
fb: figura básica
ro90: rotar
es: espejar
r45: rot45
ap: apilar
j:juntar
en: encimar
md: modDim
ra: rotAlpha
-}