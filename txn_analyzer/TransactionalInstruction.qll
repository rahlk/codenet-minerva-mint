import java

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

/**
 * Defines the transactional instructions, which are either methods with transactional
 * annotations or JDBC transaction methods.
 */
class TransactionalInstruction extends MethodAccess {
  TransactionalInstruction() {
    isTransactionalAnnotatedMethod(this.getMethod()) or isJdbcTransactionMethod(this.getMethod())
  }
}
