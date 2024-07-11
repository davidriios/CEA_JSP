<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean"/>
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject"/>
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

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
StringBuffer sbSql = new StringBuffer();
String mode = request.getParameter("mode");
String code = request.getParameter("code");
String tipo = "";
String fg=request.getParameter("fg");
boolean viewMode = false;
boolean viewModeInv = false;
boolean viewModeConta = false;

if (mode == null) mode = "add";
if (fg == null) fg = "INV";
if(fg.trim().equals("INV")&&!mode.trim().equals("add")) viewModeInv=true;
if(fg.trim().equals("CONTA")) viewModeConta=true;

if (request.getMethod().equalsIgnoreCase("GET")) {

    sbSql = new StringBuffer();
	sbSql.append("select getCta(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CXP_PROV',1) cta1,getCta(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CXP_PROV',2) cta2,getCta(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CXP_PROV',3) cta3,getCta(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CXP_PROV',4) cta4,getCta(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CXP_PROV',5) cta5,getCta(");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'CXP_PROV',6) cta6,(select descripcion from tbl_con_catalogo_gral cg where compania=");
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(" and cta1||'.'||cta2||'.'||cta3||'.'||cta4||'.'||cta5||'.'||cta6 = get_sec_comp_param(cg.compania,'CXP_PROV') ) as ctaFinanciera,get_sec_comp_param(");	 
	sbSql.append((String) session.getAttribute("_companyId"));
	sbSql.append(", 'COMP_ASIGNA_CTA_PROV') as asigaCta   FROM DUAL");
	CommonDataObject _cd = SQLMgr.getData(sbSql.toString());
	

	if (mode.equalsIgnoreCase("add")) {
		cdo = new CommonDataObject();
		cdo.addColValue("codigo","0");
		cdo.addColValue("ruc","");
		cdo.addColValue("vetado","N");
		if(!_cd.getColValue("ctaFinanciera").trim().equals("") && _cd.getColValue("asigaCta").trim().equals("S") ){
		cdo.addColValue("cta1",""+_cd.getColValue("cta1"));
		cdo.addColValue("cta2",""+_cd.getColValue("cta2"));
		cdo.addColValue("cta3",""+_cd.getColValue("cta3"));
		cdo.addColValue("cta4",""+_cd.getColValue("cta4"));
		cdo.addColValue("cta5",""+_cd.getColValue("cta5"));
		cdo.addColValue("cta6",""+_cd.getColValue("cta6"));
		cdo.addColValue("afecta_mor","S");
		cdo.addColValue("ctaFinanciera",""+_cd.getColValue("ctaFinanciera"));
		}
		
	} else {
		if (code == null) throw new Exception("El proveedor no es válido. Por favor intente nuevamente!");
		sbSql = new StringBuffer();
		sbSql.append("SELECT a.tipo_pago, a.dia_limite, a.cod_provedor as codigo, a.ruc, a.nombre_proveedor as nombre, a.direccion, a.telefono, a.fax, a.apartado_postal as apartado, a.estado_proveedor as estado, a.cat_cta1 as cta1, a.cat_cta2 as cta2, a.cat_cta3 as cta3, a.cat_cta4 as cta4, a.cat_cta5 as cta5, a.cat_cta6 as cta6, nvl(a.email,'EMAIL@EMAIL.COM') as email, a.representante, a.contacto_compra as contacto, a.zona_postal as zona, nvl(a.tipo_prove,' ') as tipoCode, a.digito_verificador as dv, a.local_internacional, a.tipo_persona, a.ruta_transito as ruta, a.tipo_cuenta as tipoCuenta, a.cuenta_bancaria as cuentaBanco, nvl((select descripcion from tbl_con_catalogo_gral where cta1 = a.cat_cta1 and cta2 = a.cat_cta2 and cta3 = a.cat_cta3 and cta4 = a.cat_cta4 and cta5 = a.cat_cta5 and cta6 = a.cat_cta6 and compania = a.compania),' ') as ctaFinanciera, nvl((select descripcion from tbl_com_tipo_proveedor where tipo_proveedor = a.tipo_prove),' ') as tipo, nvl((select nombre_banco from tbl_adm_ruta_transito where ruta = a.ruta_transito),' ') as rutaname,nvl(a.vetado,'N') as vetado,a.comentario,afecta_mor FROM tbl_com_proveedor a WHERE a.compania = ");
		sbSql.append(session.getAttribute("_companyId"));
		sbSql.append(" and a.cod_provedor = ");
		sbSql.append(code);
		cdo = SQLMgr.getData(sbSql);
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title="Proveedor - "+document.title;
function openWindow(op){switch(op){case 1:abrir_ventana1('../compras/proveedor_tipo_list.jsp');break;case 2:abrir_ventana1('../contabilidad/ctabancaria_catalogo_list.jsp?id=4');break;case 3:abrir_ventana1('../rhplanilla/list_ruta.jsp');break;}}
function setDias(val){if(val==2){document.form1.diaLimite.className='FormDataObjectEnabled';document.form1.diaLimite.disabled=false;}else{document.form1.diaLimite.className='FormDataObjectDisabled';document.form1.diaLimite.disabled=true;}}
function doAction(){setDias(document.form1.tipoPago.value);validCampo(document.form1.vetado.value);}
function validCampo(value){if(document.form1.vetadoOld.value=="S"||document.form1.vetado.value=="S"){document.form1.comentario.className='FormDataObjectRequired';}else{document.form1.comentario.className='FormDataObjectEnabled';}}

function checkCampo(){if((document.form1.vetadoOld.value=="S"||document.form1.vetado.value=="S") && document.form1.comentario.value.trim()==''){CBMSG.warning('Introduzca motivo por el que se ha Cambiado Vetado a dicho Proveedor..');return true;}
else{return false;} }
function checkRuc(obj)
{
		if(obj.value.trim()=='')
		{
			 CBMSG.warning('Introduzca valor en campo RUC! Revise..')
		}
		else
		{
			if(document.form1.tipoDePersona.value != '3'){
			if(duplicatedDBData('<%=request.getContextPath()%>','<%=mode%>',obj,'tbl_com_proveedor',' ruc=\''+replaceAll(obj.value,'\'','\'\'')+'\' and compania=<%=session.getAttribute("_companyId")%>','<%=cdo.getColValue("ruc").trim()%>'))
			{
					 document.form1.ruc.value = '';
					 return true;
			}
			else  return false;
			}else  return false;
		}

}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="COMPRAS - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="5" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("code",code)%>
<%=fb.hidden("vetadoOld",cdo.getColValue("vetado"))%>
<%=fb.hidden("fg",fg)%>
		<tr class="TextRow02">
			<td colspan="4">&nbsp;</td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel>Proveedor</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Tipo De Persona</cellbytelabel></td>
			<td colspan="3"><%=fb.select("tipoDePersona","1=NATURAL,2=JURIDICO,3=EXTRANJERO",cdo.getColValue("tipo_persona"),true,false,(viewMode||viewModeConta),0,null,null,null,null,"S")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Local/Internacional</cellbytelabel></td>
			<td colspan="3"><%=fb.select("localInt","1=LOCALES,2=INTERNACIONAL",cdo.getColValue("local_internacional"),true,false,(viewMode||viewModeConta),0,null,null,null,null,"S")%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Identificaci&oacute;n</cellbytelabel></td>
			<td colspan="3"><%=fb.intBox("codigo",cdo.getColValue("codigo"),true,(viewMode||viewModeConta),true,5)%><%=fb.textBox("nombre",cdo.getColValue("nombre"),true,(viewMode||viewModeConta),false,39)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Tipo Proveedor</cellbytelabel></td>
			<td colspan="3"><%=fb.textBox("tipoCode",cdo.getColValue("tipoCode"),false,(viewMode||viewModeConta),true,5)%><%=fb.textBox("tipo",cdo.getColValue("tipo"),false,(viewMode||viewModeConta),true,39)%><%=fb.button("btntipo","...",true,(viewMode||viewModeConta),null,null,"onClick=\"javascript:openWindow(1)\"")%></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%"><cellbytelabel>R.U.C. / C&eacute;dula / Pasaporte</cellbytelabel> </td>
			<td width="39%"><%=fb.textBox("ruc",cdo.getColValue("ruc"),(fg.trim().equals("CONTA")?false:true),(viewMode||viewModeConta),false,50,30,null,null,"onBlur=\"javascript:checkRuc(this)\"")%></td>
			<td width="10%">D.V.</td>
			<td width="36%"><%=fb.intBox("dv",cdo.getColValue("dv"),(fg.trim().equals("CONTA")?false:true),(viewMode||viewModeConta),false,4,2)%></td>
		</tr>
		<tr class="TextRow01">
			<td width="15%"><cellbytelabel>T&eacute;rmino Pago</cellbytelabel></td>
			<td width="39%"><%=fb.select("tipoPago","1=CONTADO,2=CREDITO",cdo.getColValue("tipo_pago"),true,false,(viewMode||viewModeConta),0,null,null,"onChange=\"javascript:setDias(this.value)\"",null,"S")%></td>
			<td width="10%"><cellbytelabel>L&iacute;mite</cellbytelabel></td>
			<td width="36%"><%=fb.select("diaLimite","0=-SELECCIONE-,1=15 DIAS,2=30 DIAS,3=45 DIAS,4=60 DIAS,5=90 DIAS,6=120 DIAS",cdo.getColValue("dia_limite"),false,false,0,null,null,null,"","")%></td>
		</tr>
		<tr class="TextHeader">
			<td colspan="4"><cellbytelabel>Generales del Proveedor</cellbytelabel></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Representante Legal</cellbytelabel></td>
			<td><%=fb.textBox("representante",cdo.getColValue("representante"),false,(viewMode||viewModeConta),false,50,80)%></td>
			<td><cellbytelabel>Contacto</cellbytelabel></td>
			<td><%=fb.textBox("contacto",cdo.getColValue("contacto"),false,(viewMode||viewModeConta),false,45,80)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Tel&eacute;fono</cellbytelabel></td>
			<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,(viewMode||viewModeConta),false,50,20)%></td>
			<td><cellbytelabel>Fax</cellbytelabel></td>
			<td><%=fb.textBox("fax",cdo.getColValue("fax"),false,(viewMode||viewModeConta),false,15,11)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Apartado Postal</cellbytelabel></td>
			<td><%=fb.textBox("apartado",cdo.getColValue("apartado"),false,(viewMode||viewModeConta),false,50,50)%></td>
			<td><cellbytelabel>Zona Postal</cellbytelabel></td>
			<td><%=fb.textBox("zona",cdo.getColValue("zona"),false,(viewMode||viewModeConta),false,45,20)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>E-Mail</cellbytelabel></td>
			<td><%=fb.emailBox("email",cdo.getColValue("email"),false,(viewMode||viewModeConta),false,50,100)%></td>
			<td><cellbytelabel>Estado</cellbytelabel></td>
			<td><%=fb.select("estado","ACT=ACTIVO,INA=INACTIVO",cdo.getColValue("estado"),true,false,(viewMode||viewModeConta),0,null,null,null)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Direcci&oacute;n</cellbytelabel></td>
			<td colspan="3"><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,(viewMode||viewModeConta),false,50,80)%></td>
		</tr>
		<tr class="TextRow01">
			<td><cellbytelabel>Afecta Morosidad cxp</cellbytelabel></td>
			<td colspan="3"><%=fb.select("afecta_mor","S=SI,N=NO",cdo.getColValue("afecta_mor"))%></td>
		</tr>
		<authtype type='51'>
		<tr class="TextRow01">
			<td><cellbytelabel>Cta. Financiera</cellbytelabel></td>
			<td colspan="3"><%=fb.textBox("cta1",cdo.getColValue("cta1"),false,false,true,4)%><%=fb.textBox("cta2",cdo.getColValue("cta2"),false,false,true,4)%><%=fb.textBox("cta3",cdo.getColValue("cta3"),false,false,true,4)%><%=fb.textBox("cta4",cdo.getColValue("cta4"),false,false,true,4)%><%=fb.textBox("cta5",cdo.getColValue("cta5"),false,false,true,4)%><%=fb.textBox("cta6",cdo.getColValue("cta6"),false,false,true,4)%><%=fb.textBox("ctaFinanciera",cdo.getColValue("ctaFinanciera"),false,false,true,35)%><%=fb.button("btncta","...",true,(viewModeInv || viewMode),null,null,"onClick=\"javascript:openWindow(2)\"")%></td>
		</tr></authtype>
		<authtype type='52'>
		<tr class="TextRow01">
			<td><cellbytelabel>Ruta Tr&aacute;nsito</cellbytelabel></td>
			<td><%=fb.textBox("ruta",cdo.getColValue("ruta"),false,(viewMode||viewModeInv),true,15)%>
			<%=fb.textBox("rutaname",cdo.getColValue("rutaname"),false,(viewMode||viewModeInv),true,29)%>
			<%=fb.button("btnruta","...",true,(viewMode||viewModeInv),null,null,"onClick=\"javascript:openWindow(3)\"")%></td>
			<td><cellbytelabel>Cuenta Banco</cellbytelabel></td>
			<td><%=fb.textBox("cuentaBanco",cdo.getColValue("cuentaBanco"),false,(viewMode||viewModeInv),false,20,30)%>
			
			<%=fb.select("tipoCuenta","03=CORRIENTE,04=AHORRO,07=PRESTAMO,43=TARJ. CREDITO",cdo.getColValue("tipoCuenta"),false,false,(viewMode||viewModeInv),0,null,null,"",null,"S")%>
			
			</td>
		</tr>
		</authtype>
		
		<authtype type='50'>
		<tr class="TextRow01">
			<td><cellbytelabel>Vetado</cellbytelabel></td>
			<td><%=fb.select("vetado","S=SI,N=NO",cdo.getColValue("vetado"),false,(viewMode||viewModeConta),0,null,"","onChange=\"javascript:validCampo(this.value)\"")%></td>
   
			<td colspan="2">
			<%=fb.textarea("comentario",cdo.getColValue("comentario"),false,(viewMode||viewModeConta),false,100,4,2000)%> 
			</td> 
		</tr></authtype>
		<tr class="TextRow02">
			<td colspan="4" align="right">
				<cellbytelabel>Opciones de Guardar</cellbytelabel>:
				<%=fb.radio("saveOption","N",false,viewMode,false)%><cellbytelabel>Crear Otro</cellbytelabel>
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel>Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel>Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode)%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
			</td>
		</tr>
<%
fb.appendJsValidation("\n\tif(checkCampo())error++;\n"); 
%>
<%=fb.formEnd(true)%>
		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
} else {
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	cdo = new CommonDataObject();

	cdo.setTableName("tbl_com_proveedor");
	cdo.addColValue("ruc",request.getParameter("ruc"));
	cdo.addColValue("nombre_proveedor",request.getParameter("nombre"));
	cdo.addColValue("direccion",request.getParameter("direccion"));
	cdo.addColValue("telefono",request.getParameter("telefono"));
	cdo.addColValue("fax",request.getParameter("fax"));
	cdo.addColValue("apartado_postal",request.getParameter("apartado"));
	cdo.addColValue("estado_proveedor",request.getParameter("estado"));
	cdo.addColValue("cat_cta1",request.getParameter("cta1"));
	cdo.addColValue("cat_cta2",request.getParameter("cta2"));
	cdo.addColValue("cat_cta3",request.getParameter("cta3"));
	cdo.addColValue("cat_cta4",request.getParameter("cta4"));
	cdo.addColValue("cat_cta5",request.getParameter("cta5"));
	cdo.addColValue("cat_cta6",request.getParameter("cta6"));
	cdo.addColValue("email",request.getParameter("email"));
	cdo.addColValue("representante",request.getParameter("representante"));
	cdo.addColValue("contacto_compra",request.getParameter("contacto"));
	cdo.addColValue("zona_postal",request.getParameter("zona"));
	cdo.addColValue("tipo_persona",request.getParameter("tipoDePersona"));
	cdo.addColValue("local_internacional",request.getParameter("localInt"));
    cdo.addColValue("afecta_mor",request.getParameter("afecta_mor"));
	
	
	if(request.getParameter("vetado")!=null)cdo.addColValue("vetado",request.getParameter("vetado"));
	if(request.getParameter("comentario")!=null)cdo.addColValue("comentario",request.getParameter("comentario"));
	//else cdo.addColValue("vetado",request.getParameter("vetadoOld")); 

	cdo.addColValue("tipo_pago",request.getParameter("tipoPago"));

	if (request.getParameter("diaLimite") == null || request.getParameter("diaLimite").trim().equals("")) cdo.addColValue("dia_limite","0");
	else cdo.addColValue("dia_limite",request.getParameter("diaLimite"));

	cdo.addColValue("tipo_prove",request.getParameter("tipoCode"));
	cdo.addColValue("digito_verificador",request.getParameter("dv"));

	cdo.addColValue("tipo_cuenta",request.getParameter("tipoCuenta"));
	cdo.addColValue("ruta_transito",request.getParameter("ruta"));
	cdo.addColValue("cuenta_bancaria",request.getParameter("cuentaBanco"));
	cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
	cdo.addColValue("fecha_modificacion","sysdate");

	ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
	ConMgr.setAppCtx(ConMgr.AUDIT_NOTES,"mode="+mode+"&code="+code);
	if (mode.equalsIgnoreCase("add")) {
		cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		cdo.addColValue("fecha_creacion","sysdate");
		cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		//cdo.setAutoIncCol("cod_provedor");
		cdo.addColValue("cod_provedor","get_next_vendor_code(null)");
		cdo.addPkColValue("cod_provedor","");
		cdo.setWhereClause("cod_provedor not in (select column_value as familia from table( select split((select decode(nvl(get_sec_comp_param(-1,'COM_EXCL_VENDOR_CODE'),'-'),'-','-1',get_sec_comp_param(-1,'COM_EXCL_VENDOR_CODE')) from dual ),',') from dual  ) )");
		
		SQLMgr.insert(cdo);
		code = SQLMgr.getPkColValue("cod_provedor");
	} else {
		cdo.setWhereClause("cod_provedor = "+code);
		SQLMgr.update(cdo);
	}
	ConMgr.clearAppCtx(null);
%>
<html>
<head>
<script language="javascript">
function closeWindow(){
<% if (SQLMgr.getErrCode().equals("1")) { %>
	alert('<%=SQLMgr.getErrMsg()%>');
<% if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/compras/proveedor_list.jsp")) { %>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/compras/proveedor_list.jsp")%>';
<% } else { %>
	window.opener.location = '<%=request.getContextPath()%>/compras/proveedor_list.jsp';
<% } %>
<% if (saveOption.equalsIgnoreCase("N")) { %>
	setTimeout('addMode()',500);
<% } else if (saveOption.equalsIgnoreCase("O")) { %>
	setTimeout('editMode()',500);
<% } else if (saveOption.equalsIgnoreCase("C")) { %>
	window.close();
<% } %>
<% } else throw new Exception(SQLMgr.getErrException()); %>
}
function addMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>';}
function editMode(){window.location='<%=request.getContextPath()+request.getServletPath()%>?mode=edit&code=<%=code%>&fg=<%=fg%>';}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>