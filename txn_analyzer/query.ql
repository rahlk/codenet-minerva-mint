import semmle.code.java.dataflow.DataFlow2
import TransactionFlowConfig

/**
 * The main query that outputs a JSON tuple for each taint flow path from source to sink.
 */
from Config cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select json_tuple
