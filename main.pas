// 16-10-2024
// Dijkstra's Pathfinding Algorithm
// Based on the version that I made in JS, ultimately from:
// https://www.datacamp.com/tutorial/dijkstra-algorithm-in-python

unit main;

{$ifdef FPC}
  {$mode Delphi}
{$endif}

interface

uses
  Classes, SysUtils, StrUtils, Generics.Collections,
  graph;

type
  TProgram = class
    private
      const
        _map: TArray<string> = [
	  '##########',
	  '#   #    #',
	  '# # #  # #',
	  '# # # ## #',
	  '# #    # #',
	  '# ##   # #',
	  '# #    # #',
	  '# #    # #',
	  '#    #   #',
	  '##########'
        ];
    public
      constructor create;
      function buildAdjacencyList(matrix: TArray<string>): TAdjacencyList;
  end;

implementation

constructor TProgram.create;
var
  list: TAdjacencyList;
  sorted_keys: TList<string>;

  G: TGraph;
  distances_predecessors: TShortestDistancesReturnValue;
  node: string;
  path: TList<string>;
  cell: string;
  a, b: integer;
begin
  list := buildAdjacencyList(_map);

  // Debug adjacency list
  sorted_keys := TList<string>.create(list.keys);
  sorted_keys.sort;
  //for row_key in sorted_keys do begin
  //  write(format('%s: ', [row_key]));
  //  writeln(string.join(', ', list[row_key].keys.ToArray))
  //end;

  G := TGraph.create(list);
  distances_predecessors := G.shortest_distances('1,1');

  // Debug distances
  //for node in distances_predecessors.distances.Keys do
  //  writeln(format('%s: %d', [
  //    node,
  //    distances_predecessors.distances[node]]));

  // Debug predecessors
  //for node in distances_predecessors.predecessors.keys do
  //  writeln(format('%s: %s', [
  //    node,
  //    distances_predecessors.predecessors[node]]));

  path := G.shortest_path('8,5', '1,1');
  writeln('Path: ' + string.join(', ', path.ToArray));

  // Debug map
  for b := 0 to high(_map) do begin
    for a := 0 to _map[b].Length do begin
      node := format('%d,%d', [a, b]);
      cell := _map[b][a + 1];

      if path.Contains(node) then
        write(padleft((path.IndexOf(node) + 1).ToString, 3))
      else write(ifthen(cell = '#', '###', '   '));
    end;
    writeln;
  end;

  writeln('1: Starting point');
  writeln(format('%d: Goal', [path.Count]));

  readln
end;


function TProgram.buildAdjacencyList(matrix: TArray<string>): TAdjacencyList;
var
  a, b: integer;
  node: string;
  current_node: TDictionary<string, integer>;
begin
  result := TAdjacencyList.create;

  for b := 0 to high(matrix) do
  for a := 0 to matrix[0].Length - 1 do begin
    if matrix[b][a + 1] = '#' then continue;

    node := format('%d,%d', [a, b]);

    if not result.ContainsKey(node) then
      result.add(node, TDictionary<string, integer>.create);

    current_node := result[node];

    // right & left
    if matrix[b][a + 2] = ' ' then
      current_node.add(format('%d,%d', [a + 1, b]), 1);
    if matrix[b][a] = ' ' then
      current_node.add(format('%d,%d', [a - 1, b]), 1);

    // up & down
    if (b + 1 <= high(matrix)) and (matrix[b + 1][a + 1] = ' ') then
      current_node.add(format('%d,%d', [a, b + 1]), 1);
    if (b - 1 <= high(matrix)) and (matrix[b - 1][a + 1] = ' ') then
      current_node.add(format('%d,%d', [a, b - 1]), 1);
  end;

end;


end.

