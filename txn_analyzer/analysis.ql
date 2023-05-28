import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.DataFlow2
import semmle.code.java.dataflow.TaintTracking

class EntryPointSource extends DataFlow::Node {
  EntryPointSource() {
    exists(Method m |
      m = this.getEnclosingCallable() and
      (
        m.getAnAnnotation().getType().hasQualifiedName("javax.ws.rs", "GET") or
        m.getAnAnnotation().getType().hasQualifiedName("javax.ws.rs", "POST") or
        m.getAnAnnotation().getType().hasQualifiedName("javax.ws.rs", "PUT") or
        m.getAnAnnotation().getType().hasQualifiedName("javax.ws.rs", "DELETE") or
        m.getAnAnnotation().getType().hasQualifiedName("org.springframework.web.bind.annotation", "RequestMapping") or
        m.getAnAnnotation().getType().hasQualifiedName("org.springframework.web.bind.annotation", "GetMapping") or
        m.getAnAnnotation().getType().hasQualifiedName("org.springframework.web.bind.annotation", "PostMapping") or
        m.getAnAnnotation().getType().hasQualifiedName("org.springframework.web.bind.annotation", "PutMapping") or
        m.getAnAnnotation().getType().hasQualifiedName("org.springframework.web.bind.annotation", "DeleteMapping") or
        (
          m.hasName(["doGet", "doPost", "doPut", "doDelete"]) and
          m.getDeclaringType().getASupertype*().hasQualifiedName("javax.servlet.http", "HttpServlet")
        )
      )
    )
  }
}

class TransactionalInstruction extends MethodAccess {
  TransactionalInstruction() {
    (
      this.getMethod().getAnAnnotation().getType().hasQualifiedName("org.springframework.transaction.annotation", "Transactional") or
      this.getMethod().getAnAnnotation().getType().hasQualifiedName("javax.ejb", ["Stateless", "Stateful", "Singleton", "MessageDriven"]) or
      this.getMethod().getAnAnnotation().getType().hasQualifiedName("javax.transaction", "Transactional")
    )
    or
    (
      this.getMethod().getDeclaringType().hasQualifiedName("java.sql", "Connection") and
      this.getMethod().hasName(["setAutoCommit", "commit", "rollback"])
    )
  }
}

class Config extends TaintTracking::Configuration {
  Config() { this = "Config" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof EntryPointSource
  }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr() instanceof TransactionalInstruction
  }
}

from Config cfg, DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
select json_tuple("source", source.toString(), "sink", sink.toString(), "path", sink.getPath().toString())
