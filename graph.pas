unit graph;

{$ifdef FPC}
  {$mode Delphi}
{$endif}

interface

uses
  Classes, SysUtils, Generics.Collections, Generics.Defaults;

type
  TAdjacencyList = TDictionary<string, TDictionary<string, integer>>;
  TPriorityQueueItem = packed record
    weight: integer;
    node: string;
  end;

  TShortestDistancesReturnValue = packed record
    distances: TDictionary<string, integer>;
    predecessors: TDictionary<string, string>
  end;

  TGraph = class
    private
      _graph: TAdjacencyList;

    public
      constructor create(graph_: TAdjacencyList);
      procedure add_edge(node1: string; node2: string; weight: integer);
      function shortest_distances(start_node: string): TShortestDistancesReturnValue;
      function shortest_path(start_node: string; target_node: string): TList<string>;
  end;

implementation


constructor TGraph.create(graph_: TAdjacencyList);
begin
  _graph := graph_
end;


procedure TGraph.add_edge(node1: string; node2: string; weight: integer);
var
  node_obj: TDictionary<string, integer>;
begin
  if not _graph.ContainsKey(node1) then begin
    node_obj := TDictionary<string, integer>.create;
    _graph.add(node1, node_obj);
  end else
    node_obj := _graph[node1];

  // This will throw a compiler error: "Error: Undefined symbol: .LjXXXX"
  //_graph[node1].add(node2, weight);
  // Always use this way instead:
  node_obj.add(node2, weight);
end;


function pqCompareFunction(a: TPriorityQueueItem; b: TPriorityQueueItem): integer;
begin
  if a.weight < b.weight then exit(-1)
  else if a.weight > b.weight then exit(1)
  else exit(0)
end;


function TGraph.shortest_distances(start_node: string): TShortestDistancesReturnValue;
var
  key: string;

  pq: TList<TPriorityQueueItem>;
  pq_item: TPriorityQueueItem;
  //queue_item: TPriorityQueueItem;
  current_distance: integer;
  current_node: string;

  visited: THashSet<string>;
  broken_path: boolean;

  neighbours: TDictionary<string, integer>;
  neighbour: string;
  weight: integer;
  tentative_distance: integer;

  node: string;
  distance: integer;
begin
  // initialise the values of all nodes with infinity
  result.distances := TDictionary<string, integer>.create;
  for key in _graph.keys do result.distances.add(key, high(integer));
  result.distances[start_node] := 0;

  // initialise a priority queue
  pq := TList<TPriorityQueueItem>.create;
  with pq_item do begin
    weight := 0;
    node := start_node;
  end;
  pq.Add(pq_item);

  //for pq_item in pq do
  //  writeln(format('[%d, "%s"]', [pq_item.weight, pq_item.node]));

  visited := THashSet<string>.create;
  broken_path := false;

  while pq.Count > 0 do begin
    // simulate heapify
    pq.Sort(TComparer<TPriorityQueueItem>.construct(@pqCompareFunction));
    current_distance := pq[0].weight;
    current_node := pq[0].node;
    pq.Remove(pq[0]);

    if visited.contains(current_node) then continue;
    visited.add(current_node);

    if not _graph.ContainsKey(current_node) then begin
      broken_path := true;
      writeln('Couldn''t find path!');
      break
    end;

    // This is necessary because when accessing _graph[current_node].keys
    //   immediately causes compiler error: "Error: Internal error 200510032".
    neighbours := _graph[current_node];

    for neighbour in neighbours.keys do begin
      weight := neighbours[neighbour];
      tentative_distance := current_distance + weight;

      if tentative_distance < result.distances[neighbour] then begin
        result.distances[neighbour] := tentative_distance;
        //pq_item := default(TPriorityQueueItem);
        with pq_item do begin
          weight := tentative_distance;
          node := neighbour;
        end;
        pq.Add(pq_item);
      end;
    end;
  end;

  // predecessors
  result.predecessors := TDictionary<string, string>.create;
  for key in _graph.keys do result.predecessors.add(key, '');

  if not broken_path then
    for node in result.distances.keys do begin
      distance := result.distances[node];
      for neighbour in _graph[node].keys do
        if result.distances[neighbour] = distance + weight then
          result.predecessors[neighbour] := node;
    end;
end;


function TGraph.shortest_path(start_node: string; target_node: string): TList<string>;
var
  predecessors: TDictionary<string, string>;
  current_node: string;
begin
  result := TList<string>.create;
  predecessors := shortest_distances(start_node).predecessors;
  current_node := target_node;

  while current_node <> '' do begin
    result.Add(current_node);
    current_node := predecessors[current_node];
  end;

  result.Reverse;
end;

end.

