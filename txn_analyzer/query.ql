import java
import semmle.code.java.dataflow.DataFlow
import EntryPointSource
import TransactionalInstruction
import TransactionFlowConfig

from Config cfg, DataFlow::PathNode source, DataFlow::PathNode sink, DataFlow::PathGraph pathGraph
where cfg.hasFlowPath(source, sink)
select sink.getNode().toString(), source.getNode().toString(), pathGraph
