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
String mode = "";
String id = "";
String sql = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss");

String imageFolder = java.util.ResourceBundle.getBundle("path").getString("fotosimages");
String rootFolder = java.util.ResourceBundle.getBundle("path").getString("root");
boolean viewMode = false;

Hashtable ht = null;

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
{
	ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("fotosimages"),20,true);
	mode = (String)ht.get("mode");
	id = (String)ht.get("id")==null?"0":(String)ht.get("id");
}else{
	mode = request.getParameter("mode");
 	id = (request.getParameter("id")==null?"0":request.getParameter("id"));
 }

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add")){
		id = "0";
	}else{
		sql = "select id, primer_nombre primerNombre, primer_apellido primerApellido, segundo_nombre segundoNombre,to_char(fecha_nacimiento,'dd/mm/yyyy') fechaDeNacimiento, provincia,sigla,tomo,asiento,sexo,estado_civil maritalStatus,pasaporte,emp_id,usuario_creacion,to_char(fecha_creacion,'dd/mm/yyyy hh12:mi:ss am') fecha_creacion, fecha_modificacion, estado, segundo_apellido segundoApellido, decode(image_path,null,' ','"+imageFolder.replaceAll(rootFolder,"..")+"/'||image_path) as foto, observacion, celular, ext_tel_centro, tel_centro, email, jefe_inmediato from tbl_esc_escolta where id = "+id+"";

		escCdo = SQLMgr.getData(sql);
		if (escCdo.getColValue("emp_id") != null && !escCdo.getColValue("emp_id").trim().equals("")) viewMode = true;
    }

    if (escCdo == null) escCdo = new CommonDataObject();
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Escolta - '+document.title;

function addEscort(){
	abrir_ventana('../common/search_empleado.jsp?fp=escort');
}
function doAction(){}

function checkCedFields(evt){
    var charCode = (evt.which) ? evt.which : event.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57))
        return false;
    return true;
}

//TODO: validate ced fields

function canSubmit(){
	var provincia=document.form0.provincia.value.trim();
	var sigla=document.form0.sigla.value.trim();
	var tomo=document.form0.tomo.value.trim();
	var asiento=document.form0.asiento.value.trim();
	var pasaporte=document.form0.pasaporte.value.trim();
	var foto=eval('document.form0.foto').value;

	var provinciaE='<%=escCdo.getColValue("provincia")==null?"":escCdo.getColValue("provincia")%>';
	var siglaE='<%=escCdo.getColValue("sigla")==null?"":escCdo.getColValue("sigla").trim().replaceAll("'","\\\\'")%>';
	var tomoE='<%=escCdo.getColValue("tomo")==null?"":escCdo.getColValue("tomo")%>';
	var asientoE='<%=escCdo.getColValue("asiento")==null?"":escCdo.getColValue("asiento")%>';
	var pasaporteE='<%=escCdo.getColValue("pasaporte")==null?"":escCdo.getColValue("pasaporte")%>';
	var fotoE = '<%=escCdo.getColValue("foto")==null?"":escCdo.getColValue("foto")%>';

	var estado = "A";
	var primerNombre = document.form0.primerNombre.value.trim();
	var primerApellido = document.form0.primerApellido.value.trim();
	var mode = "<%=mode%>";
	var flag = true;

	if((provincia==''||sigla==''||tomo==''||asiento=='')&&pasaporte==''){
		flag = false;
		alert("Por favor indique una cédula o un pasaporte!");
	}else
	if(pasaporte=='' && !isAValidCed(provincia,tomo,asiento)){
		 flag = false;
		 alert("Solamente la casilla 2 de la cédula acepta valores que no sean enteros!");
	}else
	if ((provincia!=''||sigla!=''||tomo!=''||asiento!='')&&pasaporte!=''){
		flag = false;
		alert("Usted debe indicar o la cédula o el pasaporte!");
	}
	else if(primerNombre==''||primerApellido==''){
		flag = false;
		alert("Usted debe introducir el primer Nombre igual que el primer Apellido");
	}
	else{
		if (mode.trim() == "add"){
			if ( isDup(provincia,sigla,tomo,asiento,pasaporte,estado) ){
				flag = false;
				alert("Este Anfitrión ya esta registrado y esta activo!<>"+foto);
			}else
			if (foto==''){
				flag=false;
				alert('Por favor se necesita la foto del Anfitrión Escolta!');
			}
		}else{
			if ((provincia!=provinciaE||sigla!=siglaE||tomo!=tomoE||asiento!=asientoE)||pasaporte!=pasaporteE){
				if ( isDup(provincia,sigla,tomo,asiento,pasaporte,estado) ){
					flag = false;
					alert("Este Anfitrión ya esta registrado y esta activo!");
				}
			}else
			if (foto=='' && fotoE==''){
				flag=false;
				alert('Por favor se necesita la foto del Anfitrión Escolta!'+foto+' '+fotoE);
			}
		}
	}

	//console.log("thebrain the cooker says...:::::::::::::::::::::::::::::: flag = "+flag);
	return flag;
}

function isAValidCed(p,t,a){
	var pat = /^\d+$/;
    return (pat.test(p) && pat.test(t) && pat.test(a));
}

function isDup(provincia,sigla,tomo,asiento,pasaporte,estado){
	if(hasDBData('<%=request.getContextPath()%>','tbl_esc_escolta','((provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento =\''+asiento+'\') or (pasaporte = \''+pasaporte+'\')) and estado =\''+estado+'\'','')){
		return true;
	}
	return false;
}

function _doSubmit(){
	if (canSubmit())  document.form0.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION - MANTENIMIENTO - ESCOLTA"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
				<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST,null, FormBean.MULTIPART);%>
				<%=fb.formStart(true)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("baction","")%>
				<%=fb.hidden("empId","")%>
				<%=fb.hidden("fotoTmp","")%>
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
									<%=fb.intBox("provincia",escCdo.getColValue("provincia"),false,false,viewMode,3,2,null,null,"onkeypress=\"return checkCedFields(event)\"")%>
									<%=fb.textBox("sigla",escCdo.getColValue("sigla"),false,false,viewMode,3,2,null,null,"")%>
									<%=fb.intBox("tomo",escCdo.getColValue("tomo"),false,false,viewMode,5,4,null,null,"onkeypress=\"return checkCedFields(event)\"")%>
									<%=fb.intBox("asiento",escCdo.getColValue("asiento"),false,false,viewMode,6,6,null,null,"onkeypress=\"return checkCedFields(event)\"")%>

									<%=fb.button("btnEscort","...",true,(mode.equals("edit")&&escCdo.getColValue("emp_id").trim().equals("")),null,null,"onClick=\"javascript:addEscort()\"")%>

								</td>
								<td width="10%">o <cellbytelabel>Pasaporte</cellbytelabel></td>
								<td width="30%" ><%=fb.textBox("pasaporte",escCdo.getColValue("pasaporte"),false,false,viewMode,20,20,null,null,"")%></td>
							</tr>

							<tr class="TextRow01">
								<td colspan="2"><cellbytelabel>Primer Nombre</cellbytelabel></td>
								<td><%=fb.textBox("primerNombre",escCdo.getColValue("primerNombre"),true,false,viewMode,30,30,null,null,"")%></td>
								<td><cellbytelabel>Primer Apellido</cellbytelabel>
									<%=fb.textBox("primerApellido",escCdo.getColValue("primerApellido"),true,false,viewMode,30,30,null,null,"")%>
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
								<td><%=fb.textBox("segundoNombre",escCdo.getColValue("segundoNombre"),false,false,viewMode,30,30,null,null,"")%></td>
								<td><cellbytelabel>Segundo Apellido</cellbytelabel>
									<%=fb.textBox("segundoApellido",escCdo.getColValue("segundoApellido"),false,false,viewMode,30,30,null,null,"")%>
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
							<tr class="TextRow01">
								<td colspan="2"><cellbytelabel>Tel&eacute;fono Centro</cellbytelabel></td>
								<td><%=fb.textBox("telCentro",escCdo.getColValue("tel_centro"),false,false,false,10,8,null,null,"")%></td>
								<td><cellbytelabel>Ext.</cellbytelabel>
									<%=fb.textBox("extTelCentro",escCdo.getColValue("ext_tel_centro"),false,false,false,4,4,null,null,"")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<cellbytelabel>E-mail</cellbytelabel>
									<%=fb.textBox("email",escCdo.getColValue("email"),false,false,false,30,100,null,null,"")%>
								</td>
								<td colspan="2">
									<cellbytelabel>Celular</cellbytelabel>
									<%=fb.textBox("celular",escCdo.getColValue("celular"),false,false,false,10,9,null,null,"")%>
									&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
									<cellbytelabel>Jefe Inmediato:</cellbytelabel>
									<%=fb.textBox("jefe_inmediato",escCdo.getColValue("jefe_inmediato"),false,false,false,30,40,null,null,"")%>
								</td>
							</tr>
							<tr class="TextRow01">
								<td colspan="2"><cellbytelabel>Foto</cellbytelabel></td>

								<td><%=fb.fileBox("foto", escCdo.getColValue("foto"),true,false,16)%></td>
								<td align="right"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>
								<td colspan="2">
									<!--String objName, String objValue, boolean isRequired, boolean isDisabled, boolean isReadonly, int width, int height, int maxLength, String className, String style, String event-->
									<%=fb.textarea("observacion",escCdo.getColValue("observacion"),false,false,false,47,2,1000,null,null,"")%>
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
		String saveOption = (String)ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
		String baction = (String)ht.get("baction");
		String foto = ((String)ht.get("foto"))!=null && !((String)ht.get("foto")).equals("")?(String)ht.get("foto"):(String)ht.get("fotoTmp");

		System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::: saveOption = "+(String)ht.get("fechaDeNacimiento"));

		escCdo = new CommonDataObject();

  		escCdo.setTableName("tbl_esc_escolta");
		escCdo.addColValue("primer_nombre", (String)ht.get("primerNombre"));
		escCdo.addColValue("segundo_nombre",(String)ht.get("segundoNombre"));
		escCdo.addColValue("fecha_nacimiento",(String)ht.get("fechaDeNacimiento"));
		escCdo.addColValue("primer_apellido",(String)ht.get("primerApellido"));
		escCdo.addColValue("provincia",(String)ht.get("provincia"));
		escCdo.addColValue("pasaporte",(String)ht.get("pasaporte"));
		escCdo.addColValue("sigla",(String)ht.get("sigla"));
		escCdo.addColValue("tomo",(String)ht.get("tomo"));
		escCdo.addColValue("asiento",(String)ht.get("asiento"));
		escCdo.addColValue("sexo",(String)ht.get("sexo"));
		escCdo.addColValue("estado_civil",(String)ht.get("maritalStatus"));
		escCdo.addColValue("emp_id",(String)ht.get("empId"));

		escCdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		escCdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

		escCdo.addColValue("estado",(String)ht.get("escortStatus"));
		escCdo.addColValue("segundo_apellido",(String)ht.get("segundoApellido"));

		escCdo.addColValue("image_path",foto);

		escCdo.addColValue("observacion",(String)ht.get("observacion"));
		escCdo.addColValue("celular",(String)ht.get("celular"));
		escCdo.addColValue("tel_centro",(String)ht.get("telCentro"));
		escCdo.addColValue("ext_tel_centro",(String)ht.get("extTelCentro"));
		escCdo.addColValue("email",(String)ht.get("email"));
		escCdo.addColValue("jefe_inmediato",(String)ht.get("jefe_inmediato"));

	  if (mode.equalsIgnoreCase("add")){

	  		escCdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			escCdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

			escCdo.setAutoIncCol("id");

			SQLMgr.insert(escCdo);
			id = escCdo.getAutoIncCol();
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
			escCdo.addColValue("usuario_creacion",(String)ht.get("usuarioCreacion"));
		    escCdo.addColValue("fecha_creacion",(String)ht.get("fechaCreacion"));

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
	window.opener.location = '<%=request.getContextPath()%>/escolta/escolta_list.jsp';
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