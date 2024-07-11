<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<%
CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String displayArea = request.getParameter("displayArea");
String pacId = request.getParameter("pacId");
String admision = request.getParameter("admision");
String doSimpleBlinking = request.getParameter("doSimpleBlinking")==null?"0":request.getParameter("doSimpleBlinking");
if (displayArea == null) displayArea = "";

sbSql.append("select distinct a.alert_type, (select description from tbl_sec_alert_type where id=a.alert_type) as alert_description,b.color from tbl_sec_alert a,tbl_sec_alert_type b where a.alert_type=b.id and a.status='A' and upper(a.display_area)='");
sbSql.append(displayArea.toUpperCase());
sbSql.append("' and a.pac_id=");
sbSql.append(pacId);
sbSql.append(" and nvl(a.admision,");
sbSql.append(admision);
sbSql.append(")=");
sbSql.append(admision);
sbSql.append(" order by a.alert_type desc");
al = SQLMgr.getDataList(sbSql.toString());
%>
<script language="javascript">
function doActionAlert()
{
	var r=splitRowsCols(getDBData('<%=request.getContextPath()%>','a.alert_type, count(*)','tbl_sec_alert a','a.status=\'A\' and upper(a.display_area)=\'<%=displayArea.toUpperCase()%>\' and a.pac_id=<%=pacId%> and nvl(a.admision,<%=admision%>)=<%=admision%>',' group by a.alert_type order by a.alert_type desc'));
	if(r!=null)
		for(i=0;i<r.length;i++)
		{
			var obj=document.getElementById('lbl'+r[i][0]);
			if(parseInt(r[i][1],10)>0){
			<%if(doSimpleBlinking.trim().equals("0")){%>blinkId('lbl'+r[i][0],'red','black');<%}%>
			obj.style.display='';newHeight();}
			else obj.style.display='none';
		}
}
function getList(alertType){top.showPopWin('../common/ialert_list.jsp?alertType='+alertType+'&pacId=<%=pacId%>&admision=<%=admision%>',winWidth*.65,winHeight*.65,null,null,'');}

<%if(doSimpleBlinking.trim().equals("1")){%>
$(document).ready(function(){
	$( "#effect" ).effect( "slide", {direction:"right"}, 1000, null );
});
<%}%>
</script>
<table cellpadding="0" cellspacing="0" style="cursor:pointer" width="100%" id="ac">
<tr>
<%
int width=100-(10*al.size());
if (doSimpleBlinking.trim().equals("0")){
%>
<td align="right" width="<%=width%>%">&nbsp;</td>
<%}else{%>
<td width="100%">
<div style="margin:7px 5px 7px 5px;" id="effect">
<%}%>
<%
String separator = "";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	if (i != 0) separator = " | ";
	if (doSimpleBlinking.trim().equals("0")){
%>
	<td align="center"><label id="lbl<%=cdo.getColValue("alert_type")%>" class="alert1" style="display:none; cursor:pointer;" onClick="javascript:getList(<%=cdo.getColValue("alert_type")%>)"><%=cdo.getColValue("alert_description")%></label>
	<script langauge="javascript">
	blinkId('lbl<%=cdo.getColValue("alert_type")%>','<%=cdo.getColValue("color")%>','white');
	</script></td>
	<%}else{%>
	<label id="lbl<%=cdo.getColValue("alert_type")%>" class="alert" onClick="javascript:getList(<%=cdo.getColValue("alert_type")%>)"><%=cdo.getColValue("alert_description")%></label>
	<%}%>
<%
}
if (!doSimpleBlinking.trim().equals("0")){
%>
</div>
</td>
<%}%>
</tr>
</table>
<%if (doSimpleBlinking.trim().equals("0")){%><script language="javascript">doActionAlert();</script><%}%>