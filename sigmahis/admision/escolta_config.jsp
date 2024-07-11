<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iEsp" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vEsp" scope="session" class="java.util.Vector" />
<jsp:useBean id="iSoc" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSoc" scope="session" class="java.util.Vector" />
<jsp:useBean id="iUbi" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vUbi" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CommonDataObject escCdo = new CommonDataObject();

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
String mode = request.getParameter("mode");
String id = (request.getParameter("id")==null?"0":request.getParameter("id"));
String sql = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";

	}else{
		sql = "select id, primer_nombre primerNombre, primer_apellido primerApellido, segundo_nombre segundoNombre,to_char(fecha_nacimiento,'dd/mm/yyyy') fechaDeNacimiento, provincia,sigla,tomo,asiento,sexo,estado_civil maritalStatus,pasaporte,emp_id,usuario_creacion,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, fecha_modificacion, estado, segundo_apellido segundoApellido from tbl_adm_escolta where id = "+id+"";

		escCdo = SQLMgr.getData(sql);
    }

    if (escCdo == null) escCdo = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Escolta -  Edición - '+document.title;

function addEscort(){
	abrir_ventana('../common/search_empleado.jsp?fp=escort');
}
function doAction(){

}

//TODO: validate ced fields

function canSubmit(){
	var provincia=document.form0.provincia.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var pasaporte=document.form0.pasaporte.value.trim();

	var provinciaE='<%=escCdo.getColValue("provincia")==null?"":escCdo.getColValue("provincia")%>';
	var siglaE='<%=escCdo.getColValue("sigla")==null?"":escCdo.getColValue("sigla").trim().replaceAll("'","\\\\'")%>';
	var tomoE='<%=escCdo.getColValue("tomo")==null?"":escCdo.getColValue("tomo")%>';
	var asientoE='<%=escCdo.getColValue("asiento")==null?"":escCdo.getColValue("asiento")%>';
	var pasaporteE='<%=escCdo.getColValue("pasaporte")==null?"":escCdo.getColValue("pasaporte")%>';

	var estado = "A";
	var primerNombre = document.form0.primerNombre.value.trim();
	var primerApellido = document.form0.primerApellido.value.trim();
	var mode = "<%=mode%>";
	var flag = true;

	if((provincia==''||sigla==''||tomo==''||asiento=='')&&pasaporte==''){
		flag = false;
		CBMSG.warning("Por favor indique una cédula o un pasaporte!");
	}else
	if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento)){
		 flag = false;
		 CBMSG.warning("La cédula esta malformada!");
	}else
	if ((provincia!=''||sigla!=''||tomo!=''||asiento!='')&&pasaporte!=''){
		flag = false;
		CBMSG.warning("Usted debe indicar o la cédula o el pasaporte!");
	}
	else if(primerNombre==''||primerApellido==''){
		flag = false;
		CBMSG.warning("Usted debe introducir el primer Nombre asi que el primer Apellido");
	}else{
		if (mode.trim() == "add"){
			if ( isDup(provincia,sigla,tomo,asiento,pasaporte,estado) ){
				flag = false;
				CBMSG.warning("Este Anfitrión ya esta registrado y esta activo!");
			}
		}else{
			if ((provincia!=provinciaE||sigla!=siglaE||tomo!=tomoE||asiento!=asientoE)||pasaporte!=pasaporteE){
				if ( isDup(provincia,sigla,tomo,asiento,pasaporte,estado) ){
					flag = false;
					CBMSG.warning("Este Anfitrión ya esta registrado y esta activo!");
				}
			}
		}
	}

	//console.log("thebrain the cooker says...:::::::::::::::::::::::::::::: flag = "+flag);
	return flag;
}

function isDup(provincia,sigla,tomo,asiento,pasaporte,estado){
	if(hasDBData('<%=request.getContextPath()%>','tbl_adm_escolta','((provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento =\''+asiento+'\') or (pasaporte = \''+pasaporte+'\')) and estado =\''+estado+'\'','')){
		return true;
	}
	return false;
}

function _doSubmit(){
	if (canSubmit()) document.form0.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISIÓN - MANTENIMIENTO - ESCOLTA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("empId","")%>

				<%=fb.hidden("usuarioCreacion",escCdo.getColValue("usuario_creacion"))%>
				<%=fb.hidden("fechaCreacion",escCdo.getColValue("fecha_creacion"))%>
				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
							<tr class="TextRow01">
								<td width="5%">ID</td>
								<td width="5%"><%=fb.textBox("id",id,false,false,true,5,5,null,null,"")%></td>
								<td width="20%" align="right"><cellbytelabel>C&eacute;dula</cellbytelabel></td>
								<td width="30%">
									<%=fb.intBox("provincia",escCdo.getColValue("provincia"),false,false,false,3,2,null,null,"")%>
									<%=fb.textBox("sigla",escCdo.getColValue("sigla"),false,false,false,3,2,null,null,"")%>
									<%=fb.intBox("tomo",escCdo.getColValue("tomo"),false,false,false,5,4,null,null,"")%>
									<%=fb.intBox("asiento",escCdo.getColValue("asiento"),false,false,false,6,6,null,null,"")%>

									<%=fb.button("btnEscort","...",true,false,null,null,"onClick=\"javascript:addEscort()\"")%>

								</td>
								<td width="10%">o <cellbytelabel>Pasaporte</cellbytelabel></td>
								<td width="30%" ><%=fb.textBox("pasaporte",escCdo.getColValue("pasaporte"),false,false,false,20,20,null,null,"")%></td>
							</tr>

							<tr class="TextRow01">
								<td colspan="2"><cellbytelabel>Primer Nombre</cellbytelabel></td>
								<td><%=fb.textBox("primerNombre",escCdo.getColValue("primerNombre"),true,false,false,30,30,null,null,"")%></td>
								<td><cellbytelabel>Primer Apellido</cellbytelabel>
									<%=fb.textBox("primerApellido",escCdo.getColValue("primerApellido"),true,false,false,30,30,null,null,"")%>
								</td>
								<td colspan="2">
									<cellbytelabel>Estado Civil</cellbytelabel>
									<%=fb.select("maritalStatus","ST=Soltero,CS=Casado,DV=Divorciado,UN=Unido,SP=Separado,VD=Viudo",escCdo.getColValue("maritalStatus"),false,false,0,null,null,null)%>

									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<cellbytelabel>Sexo</cellbytelabel>
									<%=fb.select("sexo","F=Femenino,M=Masculino",escCdo.getColValue("sexo"),false,false,0,null,null,null)%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td colspan="2"><cellbytelabel>Segundo Nombre</cellbytelabel></td>
								<td><%=fb.textBox("segundoNombre",escCdo.getColValue("segundoNombre"),false,false,false,30,30,null,null,"")%></td>
								<td><cellbytelabel>Segundo Apellido</cellbytelabel>
									<%=fb.textBox("segundoApellido",escCdo.getColValue("segundoApellido"),false,false,false,30,30,null,null,"")%>
								</td>
								<td colspan="2">
									<cellbytelabel>Estado Anfitri&oacute;n</cellbytelabel>
									<%=fb.select("escortStatus","A=Activo,I=Inactivo",escCdo.getColValue("status"),false,false,0,null,null,null)%>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<cellbytelabel>Fecha Nac</cellbytelabel>.
									<jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fechaDeNacimiento" />
									<jsp:param name="valueOfTBox1" value="<%=escCdo.getColValue("fechaDeNacimiento")==null?cDate.substring(0,10):escCdo.getColValue("fechaDeNacimiento")%>" />
									<jsp:param name="readonly" value="n" />
									</jsp:include>
								</td>
							</tr>
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:_doSubmit()\"")%>
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

		System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::: saveOption = "+request.getParameter("fechaDeNacimiento"));

		escCdo = new CommonDataObject();

  		escCdo.setTableName("tbl_adm_escolta");
		escCdo.addColValue("primer_nombre", request.getParameter("primerNombre"));
		escCdo.addColValue("segundo_nombre",request.getParameter("segundoNombre"));
		escCdo.addColValue("fecha_nacimiento",request.getParameter("fechaDeNacimiento"));
		escCdo.addColValue("primer_apellido",request.getParameter("primerApellido"));
		escCdo.addColValue("provincia",request.getParameter("provincia"));
		escCdo.addColValue("pasaporte",request.getParameter("pasaporte"));
		escCdo.addColValue("sigla",request.getParameter("sigla"));
		escCdo.addColValue("tomo",request.getParameter("tomo"));
		escCdo.addColValue("asiento",request.getParameter("asiento"));
		escCdo.addColValue("sexo",request.getParameter("sexo"));
		escCdo.addColValue("estado_civil",request.getParameter("maritalStatus"));
		escCdo.addColValue("emp_id",request.getParameter("empId"));

		escCdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		escCdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

		escCdo.addColValue("estado",request.getParameter("escortStatus"));
		escCdo.addColValue("segundo_apellido",request.getParameter("segundoApellido"));

	  if (mode.equalsIgnoreCase("add")){

	  		escCdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			escCdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

			escCdo.setAutoIncCol("id");

			SQLMgr.insert(escCdo);
			id = escCdo.getAutoIncCol();
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			escCdo.addColValue("usuario_creacion",request.getParameter("usuarioCreacion"));
		    escCdo.addColValue("fecha_creacion",request.getParameter("fechaCreacion"));

			escCdo.setWhereClause("id="+id+"");

			SQLMgr.update(escCdo);
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
	alert('<%=SQLMgr.getErrMsg()%>');
	window.opener.location = '<%=request.getContextPath()%>/admision/escolta_list.jsp';
	window.close();
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