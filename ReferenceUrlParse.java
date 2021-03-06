
import java.io.BufferedReader;
import java.io.IOException;
import java.net.URISyntaxException;
import java.io.InputStreamReader;
import java.net.URI;

public class ReferenceUrlParse{

  // Don't care about catching IO errors for this simple test
  public static void main(final String[] args) throws IOException, URISyntaxException{
    final String inp = getInput();
    final URI uri = new URI(inp);
    String userInfo = uri.getRawUserInfo();
    final String[] userInfoSplit;
    if (userInfo != null) {
      userInfoSplit = userInfo.split(":");
    }else{
      userInfoSplit = new String[]{"null", "null"};
    }

    System.out.println("Map(");
    System.out.println("[scheme] => "+emptyToNull(uri.getScheme()));
    System.out.println("[host] => "+emptyToNull(uri.getHost()));
    System.out.println("[port] => "+uri.getPort());
    System.out.println("[user] => "+emptyToNull(userInfoSplit.length > 0 ? emptyToNull(userInfoSplit[0]) : "null"));
    System.out.println("[pass] => "+(userInfoSplit.length > 1 ? emptyToNull(userInfoSplit[1]) : "null"));
    System.out.println("[path] => "+emptyToNull(uri.getRawPath()));
    System.out.println("[query] => "+emptyToNull(uri.getRawQuery()));
    System.out.println("[fragment] => "+emptyToNull(uri.getFragment()));
    System.out.println(")");
  }


  private static String getInput() throws IOException{
    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    return br.readLine(); // We're only interested in one line
  }

  private static String emptyToNull(final String s){
    return s == null ? "null" : (s.length() > 0 ? s : "null");
  }
}
