<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
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

CommonDataObject cdo = new CommonDataObject();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList alPar = new ArrayList();
String mode = request.getParameter("mode");
String id = (request.getParameter("id")==null?"0":request.getParameter("id"));
StringBuffer sbSql = new StringBuffer();
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");
String fg = (request.getParameter("fg")==null?"":request.getParameter("fg"));
alPar = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, descripcion as optLabelColumn from tbl_pla_parentesco where disponible_en_pm = 'S' order by 1 ",CommonDataObject.class);
if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";
	} else {
		sbSql = new StringBuffer();
		sbSql.append("select id, descripcion, monto, estado, usuario_creacion, to_char(fecha_creacion, 'dd/mm/yyyy') fecha_creacion, usuario_modificacion, to_char(fecha_modificacion, 'dd/mm/yyyy') fecha_modificacion, observacion, cant_min, cant_max, parentesco from tbl_pm_afiliado where id = ");
		sbSql.append(id);
		cdo = SQLMgr.getData(sbSql.toString());
	}

    if (cdo == null) cdo = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Plan Médico -  Afiliados - '+document.title;
function doAction(){}

function _doSubmit(valor){
	if (isAValidSubmit()){
    document.form0.baction.value=valor;
    document.form0.submit();
	}
}
function isAValidNumber(n,type) {
  if (type=="i") return (/^\d+$/.test(n+'')); //entero sin signo
  else if (type=="d") return (n.match(/^\d+(?:\.\d+)?$/)); //entero sin signo
}

function isAValidSubmit(){
    var descripcion = document.getElementById("descripcion").value;
    var monto = document.getElementById("monto").value;
    var cantMin = document.getElementById("cant_min").value;
    var cantMax = document.getElementById("cant_max").value;
    var _isvalid = true;

    if(1!=1) {alert("hahahahaha por suerte antes de que eso sea verdadero, thebrain habrá conquistado el universo :D");_isvalid = false;}
    else
    if (descripcion == "" || monto == "" || cantMin == "" || cantMax == "" ){
      alert("Por favor todos los campos con fondo amarillo son obligatorios!");
      _isvalid = false;
    }else
    if (!isAValidNumber(monto,"d")){
       alert("Por favor el campo Monto requiere un entero sin signo o un decimal!");
      _isvalid = false;
    }else
    if (!isAValidNumber(cantMin,"i")){
       alert("Por favor el campo Mín requiere un entero sin signo!");
      _isvalid = false;
    }else
    if (!isAValidNumber(cantMax,"i")){
       alert("Por favor el campo Max requiere un entero sin signo!");
      _isvalid = false;
    }else
    if (parseInt(cantMin,10) > parseInt(cantMax,10)){
       alert("Por favor corrige el rango de afiliado!");
      _isvalid = false;
    }
    return _isvalid;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value=""></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
			<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("fg",fg)%>
			<%=fb.hidden("id",id)%>
			<tr class="TextRow02">
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>
					<table width="100%" cellpadding="3" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel>Descripci&oacute;n:</cellbytelabel></td>
							<td width="35%">
								<%=fb.textBox("descripcion",cdo.getColValue("descripcion"),true,false,false,50,500,null,null,"")%>
							</td>
							<td width="10%" align="right"><cellbytelabel>Cuota Mensual:</cellbytelabel></td>
							<td width="40%">
								<%=fb.decBox("monto", cdo.getColValue("monto"), true, false, false, 12, 12.2, "text12", "", "", "", false, "", "")%>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Cant. Afiliados&nbsp; M&iacute;n:
								<%=fb.intBox("cant_min", cdo.getColValue("cant_min"), true, false, false, 3, 2, "text12", "", "", "", false, "", "")%>
								&nbsp;&nbsp;Max:
								<%=fb.intBox("cant_max", cdo.getColValue("cant_max"), true, false, false, 3, 3, "text12", "", "", "", false, "", "")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Parentesco:</cellbytelabel></td>
							<td>
								<%=fb.select("parentesco",alPar,cdo.getColValue("parentesco"),false,false,0,"Text10",null,null,null,"S")%>
							</td>
							<td align="right"><cellbytelabel>&nbsp;</cellbytelabel></td>
							<td>
							<%//=fb.intBox("edad", cdo.getColValue("edad"), false, false, false, 3, 2, "text12", "", "", "", false, "", "")%>
							</td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel>Observaci&oacute;n:</cellbytelabel></td>
							<td>
								<%=fb.textarea("observacion", cdo.getColValue("observacion"), false, false, false, 50, 3, 1000, "text12", "", "", "", false, "", "")%>
							</td>
							<td align="right"><cellbytelabel>Estado:</cellbytelabel></td>
							<td>
							<%=fb.select("estado","A=Activo,I=Inactivo",cdo.getColValue("estado"),false,false,0,null,null,null)%>
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr class="TextRow02">
				<td align="right">
					<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:_doSubmit(this.value)\"")%>
					<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
				</td>
			</tr>
			<%=fb.formEnd(true)%>
		</table>
		</td>
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
	String baction = request.getParameter("baction");

	cdo = new CommonDataObject();
	cdo.setTableName("tbl_pm_afiliado");

	if(request.getParameter("id")!=null) cdo.addColValue("id", request.getParameter("id"));
	if(request.getParameter("estado")!=null) cdo.addColValue("estado", request.getParameter("estado"));
	if(request.getParameter("descripcion")!=null) cdo.addColValue("descripcion", request.getParameter("descripcion"));
	if(request.getParameter("observacion")!=null) cdo.addColValue("observacion", request.getParameter("observacion"));
	if(request.getParameter("monto")!=null) cdo.addColValue("monto", ""+request.getParameter("monto")+"");
	if(request.getParameter("cant_min")!=null) cdo.addColValue("cant_min", request.getParameter("cant_min"));
	if(request.getParameter("cant_max")!=null) cdo.addColValue("cant_max", request.getParameter("cant_max"));
	if(request.getParameter("parentesco")!=null) cdo.addColValue("parentesco", request.getParameter("parentesco"));
	//if(request.getParameter("edad")!=null) cdo.addColValue("edad", request.getParameter("edad"));

	if(request.getParameter("baction")!=null && request.getParameter("baction").equals("Guardar")){
		if (mode.equalsIgnoreCase("add")){
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion","sysdate");
			cdo.setAutoIncCol("id");
			SQLMgr.insert(cdo);
			id = cdo.getAutoIncCol();
		} else if (mode.equalsIgnoreCase("edit")) {
			cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion", "sysdate");
			cdo.setWhereClause("id = "+id);
			SQLMgr.update(cdo);
		}
	}
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
	var fg = '<%=request.getParameter("fg")%>';
	alert('<%=SQLMgr.getErrMsg()%>');
	if(fg==""){
		window.opener.location = '<%=request.getContextPath()%>/planmedico/pm_afiliado_list.jsp';
		window.close();
	}else{opener.doRefresh(); window.close();}
<%

} else throw new Exception(SQLMgr.getErrMsg());
%>
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>