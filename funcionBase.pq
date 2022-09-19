let
    Origen = (ConsultaAuditoria as table) as table => let
        // Invocación de la función Table.Profile sobre la consulta recibida
        Origen = Table.Profile(ConsultaAuditoria),
        // Nos quedamos con las columnas que necesitamos
        #"Selección de columnas" = Table.SelectColumns(Origen,{"Column", "Count", "NullCount", "DistinctCount"}),
        #"Ajuste de tipo de datos" = Table.TransformColumnTypes(#"Selección de columnas",{{"NullCount", Int64.Type}, {"DistinctCount", Int64.Type}
    }),
        #"Renombrado de columnas" = Table.RenameColumns(#"Ajuste de tipo de datos",{{"Column", "Columna"}, {"Count", "Total de registros"}, {"NullCount", "Total de nulos"}, {"DistinctCount", "Valores únicos"}}),
        // Adición de la columna % de nulos sobre el total tras dividir Total de nulos entre Total de registros. El tipo de la columna se especifica dentro del paso
        #"Añadir % de nulos" = Table.AddColumn(#"Renombrado de columnas", "% de nulos sobre el total", each ([Total de nulos] / [Total de registros]) * 100, type number),
        // Adición de la columna % de únicos sobre el total tras dividir Valores únicos entre Total de registros. El tipo de la columna se especifica dentro del paso
        #"Añadir % de únicos" = Table.AddColumn(#"Añadir % de nulos", "% de únicos sobre el total", each ([Valores únicos] / [Total de registros]) * 100, type number),
        // Adición de la columna control nulos en base a los resultados arrojados por el % de nulos sobre el total. El tipo devuelto se especifica en la consulta
        #"Añadir Control nulos" = Table.AddColumn(#"Añadir % de únicos", "Control nulos", each if [#"% de nulos sobre el total"] > 5 then "Revisar valores nulos" else "Aceptable", type text),
        // Adición de la columna control únicosen base a los resultados arrojados por el % de únicos sobre el total. El tipo devuelto se especifica en la consulta
        #"Añadir Control únicos" = Table.AddColumn(#"Añadir Control nulos", "Control únicos", each if [#"% de únicos sobre el total"] < 100 then "Revisar valores únicos" else "Aceptable", type text)
    in
        #"Añadir Control únicos"
in
    Origen
