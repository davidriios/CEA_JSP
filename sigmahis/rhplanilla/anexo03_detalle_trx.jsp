<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String key = "";
String sql = "";
String appendFilter = "";
String anio = request.getParameter("anio");
String mode = request.getParameter("mode");
String change = request.getParameter("change");
String empId = request.getParameter("empId");
String noEmpleado = request.getParameter("noEmpleado");

StringBuffer sbSql = new StringBuffer();


boolean viewMode = false;
if (mode == null) mode = "add";
if (anio == null) anio = "";
if (empId == null) empId = "";
if (noEmpleado == null) noEmpleado = "";

if (request.getMethod().equalsIgnoreCase("GET"))
{
   
    if (!anio.trim().equals(""))
	{
		if (mode.trim().equals("add")){
			sbSql = new StringBuffer();
			sbSql.append("call sp_pla_cargar_temporal_emp(");
			sbSql.append(session.getAttribute("_companyId"));
			sbSql.append(",");
			sbSql.append(anio);
			sbSql.append(")");
			SQLMgr.execute(sbSql.toString());
			if (!SQLMgr.getErrCode().equals("1")) throw new Exception (SQLMgr.getErrException());
		}
	//	if (anio == null) throw new Exception("El Año no es válido. Por favor intente nuevamente!");
	if (!empId.trim().equals(""))appendFilter+=" and te.emp_id="+empId;
	if (!noEmpleado.trim().equals(""))appendFilter+=" and te.num_empleado='"+noEmpleado+"'";
	sql = "SELECT e.emp_id , decode(e.provincia,0,' ',00,' ',11,'B',12,'C',e.provincia)||decode(e.sigla,'00','  ','0','  ',e.sigla)||'-'||to_char(e.tomo)||'-'||to_char(e.asiento) ced_emp, DECODE(e.sigla,'E','P','P','P','N') tipo_empleado,e.primer_nombre||' '||DECODE(e.sexo,'F',DECODE(e.apellido_casada,NULL,e.primer_apellido,DECODE(e.usar_apellido_casada,'S','DE '||e.apellido_casada, e.primer_apellido)),e.primer_apellido) nombre_emp, e.num_empleado,nvl(te.escoger,'N')escoger from tbl_pla_temporal_emp te, tbl_pla_empleado e where e.compania = te.cod_compania and e.emp_id = te.emp_id and e.compania =  "+(String) session.getAttribute("_companyId")+appendFilter+" order by e.num_empleado";
	
	al=SQLMgr.getDataList(sql);
	
	}else throw new Exception("El Año no es válido. Por favor intente nuevamente!");
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;
function doAction()
{//newHeight();
}
function doSubmit(){
	var action = parent.document.form0.baction.value;
	document.form1.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/menu_base.jsp"%>
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
	  <td class="TableBorder">
		
        <table width="100%" cellpadding="0" cellspacing="1">
		
    <!-- ==========   F O R M   S T A R T   H E R E   ========== -->
	<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
	<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%> 
	   		<%=fb.hidden("tab","0")%> 
			<%=fb.hidden("anio",anio)%>
			<%=fb.hidden("baction","")%> 
			<%=fb.hidden("size",""+al.size())%> 
	       
        			<tr class="TextRow02">
						<td colspan="4" align="right">
							<%=fb.submit("save1","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
					</tr>
					<tr class="TextHeader" align="center">
                          <td width="15%">Cédula </td>
						  <td width="10%">No. Empleado</td>
                          <td width="30%">Nombre</td>
                          <td width="5%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this,0)\"","Seleccionar todos los Registros listados!")%></td>
                	</tr>
             	 	<%  for(int i=0; i<al.size(); i++)
							{
							key = al.get(i).toString();	
							CommonDataObject cdo = (CommonDataObject) al.get(i);
							String color = "TextRow01";
							if (i % 2 == 0) color = "TextRow02";
					%>
				
					<%=fb.hidden("empId"+i,cdo.getColValue("emp_id"))%> 
					
					<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
						<td><%=cdo.getColValue("ced_emp")%></td>
						<td><%=cdo.getColValue("num_empleado")%></td>
						<td align="left"><%=cdo.getColValue("nombre_emp")%></td>
                        <td align="center">
						<%=fb.checkbox("check"+i,""+i,(cdo.getColValue("escoger")!=null && cdo.getColValue("escoger").trim().equals("S")),false,null,null,"","S")%></td>
   					</tr>
					<%
					} 
					%>
			<tr class="TextRow02">
         		<td colspan="4" align="right">
				Opciones de Guardar:
            		<%=fb.radio("saveOption","O",true,viewMode,false)%>Mantener Abierto
            		<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%></td>
     		</tr><!---->
	     <%=fb.formEnd(true)%>
		
      	</table>
  		</td>
		</tr>
</table>
</body>
</html>
<%
} //GET
else
{

String saveOption 	= request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
String baction 		= request.getParameter("baction");
int keySize			= Integer.parseInt(request.getParameter("size"));


    al.clear();
	for(int i=0; i<keySize; i++)
	{ 
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_pla_temporal_emp");
		
		if(request.getParameter("check"+i) != null )
		cdo.addColValue("escoger","S");
		else cdo.addColValue("escoger","N");
		
		cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId")+" and emp_id ="+request.getParameter("empId"+i));
		al.add(cdo);
		
  	}//End For
 
 if(al.size() ==0)
 {
 	CommonDataObject cdo = new CommonDataObject();
	cdo.addColValue("escoger","N");
	cdo.setWhereClause("cod_compania="+(String) session.getAttribute("_companyId"));
	al.add(cdo);
 }
 
 SQLMgr.updateList(al);

%> 
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">

function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
  alert('<%=SQLMgr.getErrMsg()%>');
<%
    if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/anexo03_detalle_trx.jsp"))
    {
%>
  window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/anexo03_detalle_trx.jsp")%>';
<%
    }
    else
    {
%>
 // window.opener.location = '<%=request.getContextPath()%>/rhplanilla/anexo03_trx.jsp?anio=<%=anio%>&mode=edit';
<%
    }

 if (saveOption.equalsIgnoreCase("O"))
  {
%>
    setTimeout('editMode()',500);
<%
  }
  else if (saveOption.equalsIgnoreCase("C"))
  {
%>
  window.close();
<%
  }
} else throw new Exception(SQLMgr.getErrMsg());
%>
}
function editMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&anio=<%=anio%>';
}

</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>





