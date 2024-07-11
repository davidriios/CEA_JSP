<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Vector" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"  %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="OP" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="htPac" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vPac" scope="session" class="java.util.Vector" />
<jsp:useBean id="fact" scope="session" class="java.util.Hashtable" />
<%
/**
==========================================================================================
MERGE DE PACIENTES
==========================================================================================
**/
SecMgr.setConnection(ConMgr);
String tr = request.getParameter("tr");
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
String key = "";
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String change = request.getParameter("change");
boolean viewMode = false;

String fecha = request.getParameter("fecha");
if(fecha == null) fecha = CmnMgr.getCurrentDate("dd/mm/yyyy");

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (request.getMethod().equalsIgnoreCase("GET")){
	
	
		if (pacId == null) throw new Exception("Identificacion de paciente no es válido. Por favor intente nuevamente!");

		if (change==null){
			/*
			encabezado
			*/
			sbSql.append("select pac_id, exp_id, nombre_paciente, id_paciente, decode(sexo, 'F', 'FEMENINO', 'MASCULINO') sexo, edad||' a '||edad_mes||' m '||edad_dias || ' d' edad, to_char(fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento,to_char(f_nac, 'dd/mm/yyyy') as f_nac from vw_adm_paciente where pac_id = ");
			sbSql.append(pacId);
			System.out.println("sbSql.toString()="+sbSql.toString());
			cdo = SQLMgr.getData(sbSql.toString());
			/*
			detalle
			*/
			sbSql = new StringBuffer();
			sbSql.append("select pac_id, exp_id, nombre_paciente, id_paciente, sexo, edad||' a '||edad_mes||' m '||edad_dias || ' d' edad, to_char(fecha_nacimiento, 'dd/mm/yyyy') fecha_nacimiento, 'S' is_saved,to_char(f_nac, 'dd/mm/yyyy') as f_nac from vw_adm_paciente where exp_id = ");
			sbSql.append(pacId);
			sbSql.append(" and exp_id != pac_id");
			al = SQLMgr.getDataList(sbSql.toString());
			htPac.clear();
			vPac.clear();
			for(int i=0;i<al.size();i++){
				CommonDataObject cdoDet = (CommonDataObject) al.get(i);
				if ((i+1) < 10) key = "00"+(i+1);
				else if ((i+1) < 100) key = "0"+(i+1);
				else key = ""+(i+1);

				try {
					htPac.put(key, cdoDet);
					vPac.add(cdoDet.getColValue("pac_id"));
				} catch (Exception e) {
					System.out.println("Unable to addget item "+key);
				}
			}
		}
	
	session.setAttribute("OP",OP);
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Paciente - '+document.title;

function doAction(){
	//setTipoOrden();
}

function doSubmit(){
	return true;
}

function selBanco(){
	abrir_ventana1('../common/search_banco.jsp?fp=orden_pago');
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction();">
<jsp:include page="../common/title.jsp" flush="true">
<jsp:param name="title" value="RECHAZAR SOLICITUD DE MATERIALES Y MEDICAMENTOS PARA PACIENTES"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
  <tr>
    <td class="TableBorder"><table align="center" width="99%" cellpadding="0" cellspacing="1">
        <!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
        <tr>
          <td colspan="6"><table align="center" width="99%" cellpadding="0" cellspacing="1">
			<%
			fb = new FormBean("paciente","","post");
			%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("errCode","")%>
			<%=fb.hidden("errMsg","")%>
			<%=fb.hidden("saveOption","")%>
			<%=fb.hidden("clearHT","")%>
			<%=fb.hidden("action","")%>
			<%=fb.hidden("pacId",""+pacId)%>

              <tr class="TextPanel">
                <td colspan="6">Paciente</td>
              </tr>
              <tr class="TextRow01" >
                <td align="right">ID/Nombre:</td>
                <td colspan="3"><font class="RedTextBold"><%=cdo.getColValue("exp_id")%></font> / <%=cdo.getColValue("nombre_paciente")%></td>
                <td align="right">Fecha Nacimiento:</td>
                <td><%=cdo.getColValue("f_nac")%></td>
              </tr>
              <tr class="TextRow01" >
                <td align="right">Identificaci&oacute;n:</td>
                <td><%=cdo.getColValue("id_paciente")%></td>
                <td align="right">Edad:</td>
                <td><%=cdo.getColValue("edad")%></td>
                <td align="right">Sexo:</td>
                <td><%=cdo.getColValue("sexo")%></td>
              </tr>
			  <tr>
                <td colspan="6"><iframe name="itemFrame" id="itemFrame" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../admision/merge_paciente_det.jsp?change=<%=change%>&mode=<%=mode%>&pacId=<%=pacId%>"></iframe></td>
              </tr>
            </table></td>
        </tr>
        <tr>
          <td colspan="6">&nbsp;</td>
        </tr>
        <%=fb.formEnd(true)%>
        <!-- ================================   F O R M   E N D   H E R E   ================================ -->
      </table></td>
  </tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close

	//num_orden_pago = request.getParameter("num_orden_pago");
	String errCode = request.getParameter("errCode");
	String errMsg = request.getParameter("errMsg");
%>
<html>
<head>
<script language="javascript">
function unload(){closeChild=false;}
function closeWindow()
{
<%
if (errCode.equals("1")){
%>
	alert('<%=errMsg%>');
<%
if (saveOption.equalsIgnoreCase("N"))
	{
%>
	setTimeout('addMode()',500);
<%
	}
	else if (saveOption.equalsIgnoreCase("O"))
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&pacId=<%=pacId%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=add&pacId=<%=pacId%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>
