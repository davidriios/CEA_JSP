<%
String allowedHosts="127.0.0.1,0:0:0:0:0:0:0:1";
String remAddress=request.getRemoteAddr();
String[] hostsArr=allowedHosts.split(",");
boolean validIp=false;
for(int host=0;host< hostsArr.length;host++){
	if(hostsArr[host]!=null && (hostsArr[host].equals(remAddress) || hostsArr[host].equals("*"))) validIp=true;
}
if(!validIp) response.sendError(403, "Acceso Prohibido desde"+remAddress);
%>