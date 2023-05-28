import java
import semmle.code.java.dataflow.DataFlow
import EntryPointSource
import TransactionalInstruction
import TransactionFlowConfig

/**
 * The main query that outputs a JSON tuple for each taint flow path from source to sink.
 */
from Config cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select sink.getNode().toString(), source.getNode().toString(), source.getPath().toString()
