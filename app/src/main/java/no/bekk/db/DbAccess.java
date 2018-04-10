package no.bekk.db;

import java.sql.*;

public class DbAccess {
  private Connection connect = null;
  private Statement statement = null;
  private ResultSet resultSet = null;
  private String password = null;
  private String dbUrl = null;
  private String dbJdbcUrl = null;


  public DbAccess() {
    password = System.getProperty("db.password");
    dbUrl = System.getProperty("db.url");
    dbJdbcUrl = String.format("jdbc:mysql://%s:3306", dbUrl);
    try {
      connect = DriverManager.getConnection(dbJdbcUrl, "root", password);
      System.out.println("Database connected!");
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

  public String sayNow() {
    try {
      statement = connect.createStatement();
      resultSet = statement.executeQuery("SELECT NOW()");
      String message = null;
      while (resultSet.next()) {
        message = resultSet.getString(1);
      }
      return message + " :)";
    } catch (Exception e) {
      e.printStackTrace();
      return "nothing :(";
    } finally {
      close();
    }

  }

  private void close() {
    try {
      if (resultSet != null) {
        resultSet.close();
      }

      if (statement != null) {
        statement.close();
      }

      if (connect != null) {
        connect.close();
      }
    } catch (Exception e) {

    }
  }

}
