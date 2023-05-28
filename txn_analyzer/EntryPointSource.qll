import java
import semmle.code.java.dataflow.DataFlow

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

/**
 * Defines the entry point sources, which are HTTP methods in RESTful services
 * and servlets in Java EE applications.
 */
class EntryPointSource extends DataFlow::Node {
  EntryPointSource() {
    exists(Method m |
      m = this.getEnclosingCallable() and
      (isRestMethod(m) or isServletMethod(m))
    )
  }
}
