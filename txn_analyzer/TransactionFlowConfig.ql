Copy code
import semmle.code.java.dataflow.TaintTracking
import EntryPointSource
import TransactionalInstruction

/**
 * Configuration for the taint tracking from entry point sources to transactional instructions.
 */
class Config extends TaintTracking::Configuration {
  Config() { this = "Config" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof EntryPointSource
  }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr() instanceof TransactionalInstruction
  }
}
