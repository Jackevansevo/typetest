module Utils exposing (countMisstyped, counter, padList)

import Dict exposing (Dict)
import Model exposing (KeyComparison)


padList : List a -> a -> Int -> List a
padList list pad length =
    List.append list (List.repeat (length - List.length list) pad)


counter : List comparable -> Dict comparable Int
counter items =
    items
        |> List.foldr
            (\item carry ->
                Dict.update
                    item
                    (\existingCount ->
                        case existingCount of
                            Just count ->
                                Just (count + 1)

                            Nothing ->
                                Just 1
                    )
                    carry
            )
            Dict.empty


countMisstyped typed target =
    let
        comparisons =
            List.map2 (\a b -> KeyComparison a b (a == b)) typed target
    in
    List.reverse (List.sortBy (\( a, b ) -> b) (Dict.toList (counter (List.map .target (List.filter (\c -> not c.correct) comparisons)))))
