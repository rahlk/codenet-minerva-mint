/**
 * Library Imports.
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.DataFlow2
import semmle.code.java.dataflow.TaintTracking

/**
 * Defines the entry point sources, which are HTTP methods in RESTful services
 * and servlets in Java EE applications.
 */
class EntryPointSource extends DataFlow::Node {
  EntryPointSource() {
    exists(Method m |
      m = this.getEnclosingCallable() and
      isRestMethod(m) or isServletMethod(m)
    )
  }

  /**
   * Checks if the method is a RESTful service method.
   */
  predicate isRestMethod(Method m) {
    m.getAnAnnotation().getType().hasQualifiedName("javax.ws.rs", ["GET", "POST", "PUT", "DELETE"]) or
    m.getAnAnnotation().getType().hasQualifiedName("org.springframework.web.bind.annotation", ["RequestMapping", "GetMapping", "PostMapping", "PutMapping", "DeleteMapping"])
  }

  /**
   * Checks if the method is a servlet method.
   */
  predicate isServletMethod(Method m) {
    m.hasName(["doGet", "doPost", "doPut", "doDelete"]) and
    m.getDeclaringType().getASupertype*().hasQualifiedName("javax.servlet.http", "HttpServlet")
  }
}

/**
 * Defines the transactional instructions, which are either methods with transactional
 * annotations or JDBC transaction methods.
 */
class TransactionalInstruction extends MethodAccess {
  TransactionalInstruction() {
    isTransactionalAnnotatedMethod(this.getMethod()) or isJdbcTransactionMethod(this.getMethod())
  }

  /**
   * Checks if the method is annotated with transactional annotations.
   */
  predicate isTransactionalAnnotatedMethod(Method m) {
    m.getAnAnnotation().getType().hasQualifiedName("org.springframework.transaction.annotation", "Transactional") or
    m.getAnAnnotation().getType().hasQualifiedName("javax.ejb", ["Stateless", "Stateful", "Singleton", "MessageDriven"]) or
    m.getAnAnnotation().getType().hasQualifiedName("javax.transaction", "Transactional")
  }

  /**
   * Checks if the method is a JDBC transaction method.
   */
  predicate isJdbcTransactionMethod(Method m) {
    m.getDeclaringType().hasQualifiedName("java.sql", "Connection") and
    m.hasName(["setAutoCommit", "commit", "rollback"])
  }
}

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

/**
 * The main query that outputs a JSON tuple for each taint flow path from source to sink.
 */
from Config cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select json_tuple("source", source.toString(), "sink", sink.toString(), "path", sink.getPath().toString())
