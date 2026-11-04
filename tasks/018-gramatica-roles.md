# 018 · Gramática: roles de las palabras (datos)

Estado: APROBADA
Peldaño inicial: 2
Revisión: no

## Objetivo
Asignar a cada palabra HSK1-3 su rol sintáctico para el bombo y el corrector por reglas de orden.

## Archivos permitidos
- lib/data/grammar_roles.dart (nuevo; archivo de datos, puede pasar de 200 líneas)
- test/grammar_roles_test.dart (nuevo)

## Criterios de aceptación
- [ ] `enum Role {subject, time, place, manner, verb, object, adjective, measure, number, aspect, comparison, negation, demonstrative, youYou}` (manner = CCM; aspect = 了/会; comparison = 比/很; negation = 不/没有; demonstrative = 那/哪/那儿/哪里/哪儿…; youYou = 又…又).
- [ ] `Map<String, Set<Role>> grammarRoles` por hanzi para las palabras hsk1-hsk3 de assets/vocab.json (pronombres → subject/object; sustantivos → object y, si procede, place/time; etc.).
- [ ] Test: ≥ 90% de las palabras HSK1 tienen rol; 我 ∈ subject; 今天 ∈ time; 吃 ∈ verb; 了 ∈ aspect; 个 ∈ measure; 比 ∈ comparison; 没有 ∈ negation; 哪儿 ∈ demonstrative.

## Comando de verificación
`flutter test test/grammar_roles_test.dart && flutter analyze lib test`

## Límite de pasos
20

## Dudas

## Resultado

Aprobada tras arreglos de Claude/Sonnet: suite completa 141 tests OK y analyze limpio.
