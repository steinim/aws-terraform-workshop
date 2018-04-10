package no.bekk.jersey.resources;

import no.bekk.db.DbAccess;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;
import java.net.InetAddress;

import static javax.ws.rs.core.MediaType.TEXT_PLAIN;

@Path("/")
public class RootResource {

  private DbAccess dbAccess = new DbAccess();

  @GET
  @Produces(TEXT_PLAIN)
  public Response ping() throws Exception {
    return Response.ok("App says: I'm alive on " + InetAddress.getLocalHost().getHostName() + " :)\n\nDB says the current date and time is: " + dbAccess.sayNow()).build();
  }

}
