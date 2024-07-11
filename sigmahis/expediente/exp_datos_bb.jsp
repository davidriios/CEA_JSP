<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.expediente.BalanceHidrico"%>
<%@ page import="issi.expediente.DetalleBalance"%>
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

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdoP = new CommonDataObject(); //En caso de partos múltiples, para conservar el mismo pediatra
CommonDataObject cdoPacId_bb = new CommonDataObject();

boolean viewMode = false;
String mode = request.getParameter("mode");
String tab = request.getParameter("tab");
String change = request.getParameter("change");
String sql = "";
String seccion = request.getParameter("seccion");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");

String codPac = request.getParameter("codPac");
String dob = request.getParameter("dob");

String fecha_eval = request.getParameter("fecha_eval");
String key = "";
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String filter = "", op="", appendFilter = "";
String id = request.getParameter("id");
String pacIdMadre = request.getParameter("pacIdMadre");
String act = request.getParameter("clear");
String cedula_madre = request.getParameter("cedPas");
String fg = request.getParameter("fg");

int index = cedula_madre.lastIndexOf('-');

int size = 0;
int LElimLastLineNo = 0;
int LAdminLastLineNo = 0;
int balLastLineNo = 0;

if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view")) viewMode = true;
if (tab == null) tab = "0";
if (id == null) id = "0";
if (act == null) act = "";
if (fg == null) fg = "";

String toDay = CmnMgr.getCurrentDate("dd/mm/yyyy");

if (noAdmision == null) throw new Exception("La Admisión no es válida. Por favor intente nuevamente!");
if (pacId == null) throw new Exception("El pacId no es válido. Por favor intente nuevamente!");
if (dob == null) throw new Exception("La fecha de nacimiento no es válido. Por favor intente nuevamente!");
if (codPac == null) throw new Exception("El código del paciente no es válido. Por favor intente nuevamente!");

if(!fg.trim().equals("EDIT"))if ( !id.equals("00") && !id.equals("0")) viewMode = true;

if (request.getMethod().equalsIgnoreCase("GET"))
{
	//sql="select to_char(a.fecha,'dd/mm/yyyy') as fecha from tbl_sal_balance_hidrico where pac_id="+pacId+" and secuencia="+noAdmision+" order by fecha_creacion desc";
	sql = "select  nombre_bb||' - '||pac_id as nombre_bb ,to_char(fecha_nacimiento,'dd/mm/yyyy') fecha_nacimiento,secuencia /*pac_id */,estado,decode(estado,'A','ACTIVO','I','INACTIVO',estado)descEstado from   tbl_adm_neonato where trunc(fnac_madre) = to_date('"+dob+"','dd/mm/yyyy') and codpac_madre = "+codPac+" and admsec_madre = "+noAdmision+"  order by secuencia";
	al2 = SQLMgr.getDataList(sql);

	if((al2.size() !=0 || !id.trim().equals("0")) && !id.trim().equals("00"))		
	{	
		if(!fg.trim().equals("EDIT"))viewMode = true;

		sql="select to_char(a.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento, a.codigo_paciente, a.admision,(select substr( p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)),0,100) nombrePaciente from tbl_adm_paciente p where p.pac_id = "+pacId+" )nombre_madre, (SELECT  TO_CHAR(PM.PROVINCIA||PM.SIGLA||PM.TOMO||PM.ASIENTO) from tbl_adm_paciente PM where PM.PAC_ID = "+pacId+" )  cedula_madre 		,to_char(a. hora_nacimiento,'hh12:mi am') hora_nacimiento, decode(a.edad_madre, null,TRUNC(MONTHS_BETWEEN(SYSDATE,'"+dob+"')/12), a.edad_madre) edad_madre,a.sexo, a.peso_lb, a.peso_onz, a.talla, a.tipo_parto, a.ginecologo, a.observacion, a.fecha_mod, a.nombre_bb, a.diagnostico_mama, a.medicamentos, a.presentacion, a.pediatra, a.liquido_amniotico, a.fiebre, a.valor_fiebre, a.apgar1,a.apgar5, a.vivo_sano, a.g, a.p,a. c, a.a, a.semanas_gestacion,a. nombre_padre, a.edad_padre, a.tel_padre, a.dir_padre, a.observacion_mama, a.diagnostico_bb, a.sin_datos, a.secuencia , b.primer_nombre||decode(b.segundo_nombre,null,' ',' '||b.segundo_nombre)||'  '||b.primer_apellido||decode(b.segundo_apellido,null,' ',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,' ',' '||b.apellido_de_casada)) as pediatraNombre , c.primer_nombre||decode(c.segundo_nombre,null,' ',' '||c.segundo_nombre)||' '||c.primer_apellido||decode(c.segundo_apellido,null,' ',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,' ',' '||c.apellido_de_casada)) as nombreGinecologo,to_char(fnac_madre,'dd/mm/yyyy')fnac_madre, codpac_madre, admsec_madre,to_char(a.fecha_crea,'dd/mm/yyyy hh12:mi:ss am')fecha_crea,a.usuario_crea,to_char(a.fecha_mod,'dd/mm/yyyy hh12:mi:ss am') fecha_mod , a.usuario_mod,a.estado ,d_cedula,a.pac_id as pacId from tbl_adm_neonato a  ,tbl_adm_medico b,  tbl_adm_medico c where trunc(fnac_madre) = to_date('"+dob+"','dd/mm/yyyy') and codpac_madre = "+codPac+" and admsec_madre = "+noAdmision+" and a.pediatra = b.codigo(+) and a.ginecologo = c.codigo(+) ";		
		if(!id.trim().equals("0")) sql +=" and secuencia ="+id;
		
		cdo = SQLMgr.getData(sql);
		if (!id.trim().equals("00")) id=cdo.getColValue("secuencia");
		if (!viewMode) mode = "edit";
		  //System.out.println(":::::::::::::::::::::::::::::::: THE BRAIN IS HERE! ::::::::::::::::::::::::::::::::::::::::: "+cdo.getColValue("diagnostico_mama"));
	}	
	
	//System.out.println(" antes de cdo == null *********************  M O D E == "+mode);
	if(cdo == null || id.trim().equals("0")|| id.trim().equals("00"))		
	{
		//System.out.println(" cdo == null *********************  M O D E == "+mode);
		sql=" select substr( p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)),0,100) nombre_madre, (SELECT  TO_CHAR(PM.PROVINCIA||PM.SIGLA||PM.TOMO||PM.ASIENTO) from tbl_adm_paciente PM where PM.PAC_ID = p.pac_id )  cedula_madre, TRUNC(MONTHS_BETWEEN(SYSDATE,to_date('"+dob+"','dd/mm/yyyy'))/12) edad_madre, substr('HIJO DE '|| p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)),0,100) nombre_bb,'H'||to_char(nvl(( SELECT COUNT(*) v_count_h FROM  vw_adm_paciente pac WHERE decode(pac.tipo_id_paciente,'P',pasaporte,provincia || '-' || sigla || '-' || tomo || '-' || asiento) = decode(p.tipo_id_paciente,'P',p.pasaporte,p.provincia || '-' ||p.sigla || '-' || p.tomo || '-' || p.asiento) and d_cedula <> 'D' ),0)+1) as d_cedula from tbl_adm_paciente p where p.pac_id = "+pacId+" ";
		cdo = SQLMgr.getData(sql);
		//cdo = new CommonDataObject();
		cdo.addColValue("pac_id",pacId);
		cdo.addColValue("admsec_madre",noAdmision);
		cdo.addColValue("codpac_madre",codPac);
		cdo.addColValue("fnac_madre",dob);
		cdo.addColValue("secuencia","0");
		cdo.addColValue("fecha_nacimiento","");
		cdo.addColValue("hora_nacimiento","");
		cdo.addColValue("sin_datos","N");
		cdo.addColValue("estado","");
		//System.out.println(":::::::::::::::::::::::::::::::: PINKY IS HERE! ::::::::::::::::::::::::::::::::::::::::: "+cdo.getColValue("edad_madre"));
		if (!viewMode) mode = "add";
		
		 //En caso de partos múltiples, para conservar el mismo pediatra
		cdoP = SQLMgr.getData("select to_char(a.fecha_nacimiento,'dd/mm/yyyy')fecha_nacimiento, a.codigo_paciente, a.admision,(select substr( p.primer_nombre||decode(p.segundo_nombre,null,'',' '||p.segundo_nombre)||decode(p.primer_apellido,null,'',' '||p.primer_apellido)||decode(p.segundo_apellido,null,'',' '||p.segundo_apellido)||decode(p.sexo,'F',decode(p.apellido_de_casada,null,'',' '||p.apellido_de_casada)),0,100) nombrePaciente from tbl_adm_paciente p where p.pac_id = "+pacId+" )nombre_madre ,(SELECT  TO_CHAR(PM.PROVINCIA||PM.SIGLA||PM.TOMO||PM.ASIENTO) from tbl_adm_paciente PM where PM.PAC_ID = a.pac_id_madre )  cedula_madre		,to_char(a. hora_nacimiento,'hh12:mi am') hora_nacimiento, decode(a.edad_madre, null,TRUNC(MONTHS_BETWEEN(SYSDATE,'"+dob+"')/12), a.edad_madre) edad_madre,a.sexo, a.peso_lb, a.peso_onz, a.talla, a.tipo_parto, a.ginecologo, a.observacion, a.fecha_mod, a.nombre_bb, a.diagnostico_mama, a.medicamentos, a.presentacion, a.pediatra, a.liquido_amniotico, a.fiebre, a.valor_fiebre, a.apgar1,a.apgar5, a.vivo_sano, a.g, a.p,a. c, a.a, a.semanas_gestacion,a.nombre_padre, a.edad_padre, a.tel_padre, a.dir_padre, a.observacion_mama, a.diagnostico_bb, a.sin_datos, a.secuencia , b.primer_nombre||decode(b.segundo_nombre,null,' ',' '||b.segundo_nombre)||'  '||b.primer_apellido||decode(b.segundo_apellido,null,' ',' '||b.segundo_apellido)||decode(b.sexo,'F',decode(b.apellido_de_casada,null,' ',' '||b.apellido_de_casada)) as pediatraNombre , c.primer_nombre||decode(c.segundo_nombre,null,' ',' '||c.segundo_nombre)||' '||c.primer_apellido||decode(c.segundo_apellido,null,' ',' '||c.segundo_apellido)||decode(c.sexo,'F',decode(c.apellido_de_casada,null,' ',' '||c.apellido_de_casada)) as nombreGinecologo,to_char(fnac_madre,'dd/mm/yyyy')fnac_madre, codpac_madre, admsec_madre,to_char(a.fecha_crea,'dd/mm/yyyy hh12:mi:ss am')fecha_crea,a.usuario_crea,to_char(a.fecha_mod,'dd/mm/yyyy hh12:mi:ss am') fecha_mod , a.usuario_mod,a.estado,a.pac_id as pacId  from tbl_adm_neonato a  ,tbl_adm_medico b,  tbl_adm_medico c where trunc(fnac_madre) = to_date('"+dob+"','dd/mm/yyyy') and codpac_madre = "+codPac+" and admsec_madre = "+noAdmision+" and a.pediatra = b.codigo(+) and a.ginecologo = c.codigo(+)");
		
		if ( cdoP == null ) cdoP = new CommonDataObject();
		
	}
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Admisión - Datos del Bebe - '+document.title;
function verControl(fg,id){window.location = '../expediente/exp_datos_bb.jsp?mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&dob=<%=dob%>&codPac=<%=codPac%>&id='+id+'&cedPas=<%=cedula_madre%>&fg='+fg;}
function addControl(){window.location = '../expediente/exp_datos_bb.jsp?&mode=edit&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&dob=<%=dob%>&codPac=<%=codPac%>&id=00&act=clear&cedPas=<%=cedula_madre%>';}
function doAction(){
	var id = "<%=""+id+""%>";
	if ( id !== "0" && id !== "00" ){
		var pac_id_bb = document.getElementById("pac_id_bb").value;
		var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
		var context = '<%=request.getContextPath()%>';
		var msg = getMsg(context,clientIdentifier);
		//var msg = getDBData(context, 'message', 'tbl_par_messages', 'client_identifier = \''+clientIdentifier+'\'','');
		
		if ( msg.substring(0,15).trim() == 'PRINT_BRAZALETE'){
			if(confirm('Se crearon el registro y la admisión del bebé.\nDesea usted imprimir el brazalete?')){
				abrir_ventana('../admision/print_admision_barcode.jsp?pacId='+pac_id_bb+'&noAdmision=1&cds=17');
			}
		}else if (msg.substring(0,5).trim() == 'Error'){
			alert('Se encontró un error al tratar de crear automaticamente registros de: paciente y admisión del bebé!\nPor favor contacte el administrador o créalos manualmente!');
		}
	}
	setHeight();
}
function setHeight(){newHeight();}
function getMedicDetail(code,type){var name='',esp='';if(code!=undefined&&code!=null&&code!=''){var c=splitCols(getDBData('<%=request.getContextPath()%>','a.primer_nombre||decode(a.segundo_nombre,null,\'\',\' \'||a.segundo_nombre)||\' \'||a.primer_apellido||decode(a.segundo_apellido,null,\'\',\' \'||a.segundo_apellido)||decode(a.sexo,\'F\',decode(a.apellido_de_casada,null,\'\',\' \'||a.apellido_de_casada)) as nombre','tbl_adm_medico a','a.codigo=\''+code+'\'',''));if(c!=null){name=c[0];}}document.form1.nombreMedico.value=name;}
function showMedicoList(opt){if (opt.toLowerCase() == 'pediatra') abrir_ventana1('../common/search_medico.jsp?fp=datos_bb&fg=datos_bb&especialidad=PED&status=A');else if (opt.toLowerCase() == 'ginecologo') abrir_ventana1('../common/search_medico.jsp?fp=datos_mama&fg=datos_mama&especialidad=OBG&status=A');}
function ctrlSex(val){
	var nombre_bb = document.getElementById("nombre_bb").value;
	if ( val != "" ){
		if ( val == "F" ){
			nombre_bb = nombre_bb.replace("HIJO","HIJA");
			document.getElementById("nombre_bb").value = nombre_bb;
		}else{
			nombre_bb = nombre_bb.replace("HIJA","HIJO");
			document.getElementById("nombre_bb").value = nombre_bb;
		}
	}
}

function printData(){abrir_ventana("../expediente/print_datos_bb.jsp?pacId=<%=pacId%>&dobMadre=<%=dob%>&codMadre=<%=codPac%>&noAdmisionMadre=<%=noAdmision%>");}
function _showHide(id){
	  if ( id ) {
		    if ( document.getElementById("_datos"+id).style.display=='none' ){
		         document.getElementById("_datos"+id).style.display='block';
				 document.getElementById("_mas"+id).innerHTML='-';
		    }else{
			    document.getElementById("_datos"+id).style.display='none';
				document.getElementById("_mas"+id).innerHTML='+';
		    }
	  }
}

function deactivateBB(){
	var pacId_bb = "";
	var codPac_bb = "";
	var dob_bb = "";
	var noAdmision = 1;
	var resumeMsg = "";
	var msg = "";
		
	if (document.form1.pac_id_bb != null){
	    pacId_bb = document.form1.pac_id_bb.value; 
		codPac_bb = document.form1.codPac_bb.value; 
		dob_bb = document.form1.dob_bb.value; 
	}

	if(pacId_bb != ""){
		alert('Este Proceso Anulará la adimision del bb,\n Actualizará Las Atenciones del bb en el expediente,\n Inactivará el Paciente(bb),\n Inactivará los datos del bb');
	   if(confirm("Esta usted seguro de Continuar ?????")){	
	   	   showPopWin('../common/run_process.jsp?fp=EXP&actType=7&docType=EXP&pacId='+pacId_bb+'&docId='+pacId_bb+'&docNo='+noAdmision+'&noAdmision='+noAdmision+'&compania=<%=session.getAttribute("_companyId")%>&pacIdMadre=<%=pacId%>&codigo=<%=id%>',winWidth*.75,winHeight*.65,null,null,'');
	   }//if not confirm
	   else{alert("Proceso Cancelado!");}
		
	}//pac_id_bb <> ""
	else{alert("Hay que seleccionar el bebé!");}
}

function ctrlFever(val){
	var valor_fiebre = document.getElementById("valor_fiebre");
    if ( val == 'S' ){
	    valor_fiebre.className = "FormDataObjectEnabled";
		valor_fiebre.readOnly = false;
    }else{
	  valor_fiebre.readOnly = true;
	  valor_fiebre.value = "";
	  valor_fiebre.className = "FormDataObjectDisabled";
    }	
}
function validateDCedula(obj){

	var tipoId=document.form0.tipoId.value;
	var nextValidSecuence = 0;
		var userSecuence = 0;
	var values = new Array();
	var r;
	var dCedula = "";
	var mode = "<%=mode%>";

	if ( obj == undefined ){
		 dCedula = document.form0.d_cedula.value;
	}else{dCedula = obj.value;}

	if (dCedula.indexOf("H")>-1){
			userSecuence = parseInt(dCedula.substring(1),10);
		if(tipoId=='C')
		{
			var provincia=document.form0.provincia.value.trim();
			var sigla=document.form0.sigla.value.trim();
			var tomo=document.form0.tomo.value.trim();
			var asiento=document.form0.asiento.value.trim();
			if(isNaN(provincia)||isNaN(tomo)||isNaN(asiento))
			{
				 CBMSG.warning('Valores invalidos en numero de cedula!   Revise..')
			}
			else
			{
				r = splitRowsCols(getDBData('<%=request.getContextPath()%>','d_cedula','tbl_adm_paciente','tipo_id_paciente=\'C\' and provincia=\''+provincia+'\' and sigla=\''+replaceAll(sigla,'\'','\'\'')+'\' and tomo=\''+tomo+'\' and asiento=\''+asiento+'\' and d_cedula like \'%H%\''));
			}
		}
		else if(tipoId=='P')
		{
			var pasaporte=document.form0.pasaporte.value.trim();
			r = splitRowsCols(getDBData('<%=request.getContextPath()%>','d_cedula','tbl_adm_paciente','tipo_id_paciente=\'P\' and pasaporte=\''+replaceAll(pasaporte,'\'','\'\'')+'\' and d_cedula like \'%H%\''));
		}

		if ( r!=null){values = (""+r).replace(/[A-Za-z]/gi,"").split(",");if ( mode === "add" ){nextValidSecuence = parseInt(values.sort(function(a,b){return b-a;})[0],10) + 1;		}else{if(document.form0.old_d_cedula.value != dCedula ){
		nextValidSecuence =userSecuence;
		for (var i = 0; i < r.length; i++){if (r[i] == 'H'+nextValidSecuence){nextValidSecuence++;}

		 //nextValidSecuence = parseInt(values.sort(function(a,b){return b-a;})[0],10);
		 }
				}else{nextValidSecuence =userSecuence;}}
				if ( userSecuence != nextValidSecuence ){

					 CBMSG.warning("Lo sentimos, pero debe continuar con H"+nextValidSecuence);

					 return false;
				}else{return true;}
		}else{
				nextValidSecuence=1;
				if ( userSecuence != nextValidSecuence ){
					 CBMSG.warning("Lo sentimos, pero debe empezar con H"+nextValidSecuence);

					 return false;
				}else{return true;}
		}

	}else{return true;}
}
function istAnInvalidDob() {
  var dob=document.getElementById("fecha_nacimiento").value;
	if(isValidateDate(dob)){
		var result=getDBData('<%=request.getContextPath()%>',"'y' as res",'dual',"trunc(sysdate) < to_date('"+dob+"','dd/mm/yyyy')",'');
		if(result&&result=='y'){
			CBMSG.error("La Fecha de Nacimiento ingresada es incorrecta por favor ingresar una fecha menor o igual al día actual!");
			return true;
		}
	}else CBMSG.warning('Valor Inválido en Fecha de Nacimiento!!');
  return false;
}</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp"  flush="true">
	<jsp:param name="title" value="DATOS DEL BEBE"></jsp:param>
	<jsp:param name="displayCompany" value="n"></jsp:param>
	<jsp:param name="displayLineEffect" value="n"></jsp:param>
	<jsp:param name="useThis" value="y"></jsp:param>
</jsp:include>

<table align="center" width="100%" cellpadding="0" cellspacing="0">
<tr>
	<td>
		<table align="center" width="100%" cellpadding="0" cellspacing="0">
		<tr class="TextRow01">

			<td align="right">&nbsp;</td>
		</tr>
		<tr>
		  <td><div id="dBalance" width="100%" class="exp h200">
            <div id="detBalance" width="98%" class="child">
              <table width="100%" cellpadding="1" cellspacing="0">
                <%fb = new FormBean("listado",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
                <%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
                <%=fb.formStart(true)%> <%=fb.hidden("baction","")%>
				<%=fb.hidden("fg",""+fg)%>
                <tr class="TextHeader01">
                  <td colspan="4"><cellbytelabel id="1">Listado de Beb&eacute;s</cellbytelabel></td>
                </tr>
                <tr class="TextHeader">
                  <td width="50%"><cellbytelabel id="2">Nombre</cellbytelabel></td>
                  <td width="10%"><cellbytelabel id="3">No</cellbytelabel>.</td>
				  <td width="35%"><cellbytelabel id="4">Estado</cellbytelabel>.</td>
				  <td width="10%">&nbsp;</td>
                </tr>
                <%
for (int i=1; i<=al2.size(); i++)
{
	key = al2.get(i-1).toString();
	CommonDataObject  cdox = (CommonDataObject) al2.get(i-1);
	 String color = "TextRow02";
	 if (i % 2 == 0) color = "TextRow01";
	%>
                <%=fb.hidden("secuencia"+i,cdox.getColValue("secuencia"))%>
                <tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')" style="cursor:pointer ">
                  <td onClick="javascript:verControl('VIEW',<%=cdox.getColValue("secuencia")%>)" ><%=cdox.getColValue("nombre_bb")%></td>
                  <td onClick="javascript:verControl('VIEW',<%=cdox.getColValue("secuencia")%>)" ><%=cdox.getColValue("secuencia")%></td>
				  <td onClick="javascript:verControl('VIEW',<%=cdox.getColValue("secuencia")%>)" ><%=cdox.getColValue("descEstado")%></td>
				  <td><authtype type='50'><%=fb.button("btnEdit","Editar",false,(cdox.getColValue("estado").trim().equals("A"))?false:true,null,null,"onClick=\"javascript:verControl('EDIT',"+cdox.getColValue("secuencia")+")\"")%></authtype></td>
                </tr>
                <%
}
%>
                <%=fb.formEnd(true)%>
              </table>
            </div>
	      </div></td>
		</tr>



		<tr class="TextRow01">
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">


<!-- TAB0 DIV START HERE-->

<div class = "dhtmlgoodies_aTab">

				<table width="100%" cellpadding="1" cellspacing="1" >
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("seccion",seccion)%>
<%=fb.hidden("fg",""+fg)%>
<%//fb.appendJsValidation("parent.setPatientInfo('"+fb.getFormName()+"','iDetalle');");%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("id",id)%>
<%=fb.hidden("dob",dob)%>
<%=fb.hidden("codPac",codPac)%>
<%=fb.hidden("cedPas", cedula_madre )%>
<%
if ( !id.equals("0") && !id.equals("00") ){
	cdoPacId_bb = SQLMgr.getData("select p.pac_id pac_id_bb, to_char(P.FECHA_NACIMIENTO,'dd/mm/yyyy') dob_bb, P.CODIGO  from tbl_adm_paciente p where coalesce( decode(p.pasaporte,null,'',p.pasaporte||p.d_cedula), TO_CHAR(P.PROVINCIA||'-'||P.SIGLA||'-'||P.TOMO||'-'||P.ASIENTO||P.D_CEDULA))  = '"+cedula_madre.substring(0,cedula_madre.lastIndexOf('-'))+"H"+id+"'"); 
	
	if ( cdoPacId_bb == null ) cdoPacId_bb = new CommonDataObject();
	
	System.out.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"+cedula_madre);
	//(SELECT COUNT(*) FROM  TBL_ADM_ADMISION WHERE  PAC_ID_MADRE = "+pacId+")
//System.out.println("select p.pac_id pac_id_bb from tbl_adm_paciente p where coalesce( decode(p.pasaporte,null,'',p.pasaporte||p.d_cedula), TO_CHAR(P.PROVINCIA||'-'||P.SIGLA||'-'||P.TOMO||'-'||P.ASIENTO||P.D_CEDULA))  = '"+cedula_madre.substring(0,cedula_madre.lastIndexOf('-'))+"H"+id+"'");
	%>
<%=fb.hidden("pac_id_bb", ""+(cdoPacId_bb.getColValue("pac_id_bb")==null?"":cdoPacId_bb.getColValue("pac_id_bb")) )%> 
<%=fb.hidden("codPac_bb", ""+(cdoPacId_bb.getColValue("codigo")==null?"":cdoPacId_bb.getColValue("codigo")) )%>  
<%=fb.hidden("dob_bb", ""+(cdoPacId_bb.getColValue("dob_bb")==null?"":cdoPacId_bb.getColValue("dob_bb")) )%>   
<%}%>
<%//=fb.hidden("usuarioCreacion",balance.getUsuarioCreacion())%>
<%//=fb.hidden("fechaCreacion",balance.getFechaCreacion())%>
<%//=fb.hidden("usuarioModificacion",balance.getUsuarioModificacion())%>
<%//=fb.hidden("fechaModificacion",balance.getFechaModificacion())%>
<%//=fb.hidden("empId",balance.getEmpId())%>
<%fb.appendJsValidation("if(document.form1.fecha_nacimiento.value=='' || document.form1.hora_nacimiento.value==''){alert('Por favor, no deje en blanco fecha/hora nacimiento!'); error++;}else if (document.form1.sexo.selectedIndex==0){alert('Por favor escoge el sexo!'); error++;}");%>
<%if(mode.equalsIgnoreCase("add")) fb.appendJsValidation("if(istAnInvalidDob())error++;");%>

             <tr>
                <td colspan="6">
                   <table width="100%" cellpadding="0" cellspacing="0" >
                      <tr class="TextHeader" onClick="_showHide(3);" style="cursor:pointer; height:20px;">
                        <td colspan="5">&nbsp;<cellbytelabel id="4">DATOS DEL BEB&Eacute;</cellbytelabel></td><td align="right">[<span id="_mas3">-</span>]&nbsp;</td>
                     </tr>
                   </table>
                </td>
                
             <tr id="_datos3" style="display:block;">
               <td colspan="6">
                     <table width="100%" cellpadding="1" cellspacing="1">
              
			<tr class="TextRow02">
				<td colspan="6" align="right">&nbsp;
				<%=fb.button("btnCancel","Inactivar",false,(cdo.getColValue("estado").trim().equals("A"))?false:true,null,null,"onClick=\"javascript:deactivateBB()\"")%>
				<%=fb.button("btnAdd","Agregar",false,false,null,null,"onClick=\"javascript:addControl()\"")%>
                <%=fb.button("btnpPrint","Imprimir Todos",false,false,null,null,"onClick=\"javascript:printData()\"")%>
                </td>
                <td>&nbsp;</td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="5">Nombre del Beb&eacute;</cellbytelabel></td>
					<td colspan="5"><%=fb.textBox("nombre_bb",cdo.getColValue("nombre_bb"),true,false,true,60,100)%></td>
			</tr>
			<tr class="TextRow02">
					<td align="right" width="20%"><cellbytelabel id="6">Fecha de Nacimiento</cellbytelabel>:</td>
					<td width="15%"><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="dd/mm/yyyy"/>
									<jsp:param name="nameOfTBox1" value="fecha_nacimiento" />
									<jsp:param name="valueOfTBox1" value="<%=(id.equals("0")||id.equals("00")?toDay:cdo.getColValue("fecha_nacimiento"))%>" />
									<jsp:param name="readonly" value="<%=(!viewMode)?"n":"y"%>"/>
								</jsp:include>
								<!--
								Hijo No:<%=cdo.getColValue("d_cedula")%>
								<%=fb.select("d_cedula","H1=H1,H2=H2,H3=H3,H4=H4,H5=H5,H6=H6,H7=H7,H8=H8,H9=H9",cdo.getColValue("d_cedula"),false,viewMode,0,null,null,"")%>
								-->
								</td>
					<td width="20%" align="right"><cellbytelabel id="7">Hora Nacimiento</cellbytelabel>:</td>
					<td width="15%"><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1"/>
									<jsp:param name="format" value="hh12:mi am"/>
									<jsp:param name="nameOfTBox1" value="hora_nacimiento" />
									<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("hora_nacimiento")%>" />
									<jsp:param name="readonly" value="<%=(!viewMode)?"n":"y"%>"/>
								</jsp:include></td>
					<td width="10%" align="right"><cellbytelabel id="8">Sexo</cellbytelabel>:</td>
					<td width="20%"><%=fb.select("sexo","F=FEMENINO,M=MASCULINO",cdo.getColValue("sexo"),false,viewMode,0,null,null,"onchange=\"ctrlSex(this.value);\"",null,"S")%></td>
			</tr>
			
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="9">Peso</cellbytelabel>:</td>
					<td><%=fb.intBox("peso_lb",cdo.getColValue("peso_lb"),true,false,viewMode,5,2)%>lbs
									<%=fb.intBox("peso_onz",cdo.getColValue("peso_onz"),false,false,viewMode,5,2)%><cellbytelabel id="10">Onz</cellbytelabel></td>
					<td align="right" ><cellbytelabel id="11">Semanas de Gestaci&oacute;n</cellbytelabel>:</td>
					<td>
					<%=fb.intBox("semanas_gestacion",cdo.getColValue("semanas_gestacion"),false,false,viewMode,5,2)%></td>
					<td align="right"><cellbytelabel id="12">Naci&oacute;</cellbytelabel>:</td>
					<td>  <%=fb.select("vivo_sano","V=VIVO Y SANO,F=VIVO Y FALLECIÓ,B=VIVO Y EN OBSERVACIÓN,R=SE REANIMÓ,O=OBITO",cdo.getColValue("vivo_sano"),false,viewMode,0,null,null,null)%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="13">Presentaci&oacute;n</cellbytelabel>:</td>
					<td colspan="2"><%=fb.textBox("presentacion",cdo.getColValue("presentacion"),false,false,viewMode,30,100)%></td>
                    <td><cellbytelabel id="14">Talla</cellbytelabel>&nbsp;<%=fb.intBox("talla",cdo.getColValue("talla"),true,false,viewMode,5,3)%>&nbsp;<cellbytelabel id="15">Cms</cellbytelabel></td>
					<td align="center"><cellbytelabel id="16">Valoraci&oacute;n</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="17">L&iacute;quido Amni&oacute;tico</cellbytelabel>:</td>
					<td colspan="3"><%=fb.select("liquido_amniotico","CL=CLARO,MF=MECONIAL FLUIDO,ME=MECONIAL ESPESO,SG=SANGUINOLENTO",cdo.getColValue("liquido_amniotico"),false,viewMode,0,"S")%></td>
					<td colspan="2" rowspan="2"><cellbytelabel id="18">apgar1</cellbytelabel>:&nbsp;<%=fb.intBox("apgar1",cdo.getColValue("apgar1"),false,false,viewMode,5,2)%><br>
	<cellbytelabel id="19">apgar5</cellbytelabel>:&nbsp;<%=fb.intBox("apgar5",cdo.getColValue("apgar5"),false,false,viewMode,5,2)%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="20">Pedi&aacute;tra</cellbytelabel>:</td>
					<td colspan="3"><%=fb.textBox("pediatra",(id.equals("00")||id.equals("0")?cdoP.getColValue("pediatra"):cdo.getColValue("pediatra")),true,false,true,15,null,null,"onBlur=\"javascript:getMedicDetail(this.value,'adm')\"")%>
								<%=fb.textBox("nombreMedico",(id.equals("00")||id.equals("0")?cdoP.getColValue("pediatraNombre"):cdo.getColValue("pediatraNombre")),true,false,true,50)%>
								<%=fb.button("btnMedico","...",false,viewMode,null,null,"onClick=\"javascript:showMedicoList('pediatra')\"")%></td>
			</tr>
            
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="21">Medicamentos</cellbytelabel>:</td>
					<td colspan="3"><%=fb.textarea("medicamentos",cdo.getColValue("medicamentos"), false, false,viewMode, 50, 2,2000, "", "", "")%></td>
                    <td colspan="2" rowspan="3" style="vertical-align:text-top; padding-top:20px; font-weight:bold; color:#F00; font-size:1.1em">
                    <cellbytelabel id="22">En caso de un parto m&uacute;tiple, se recomienda ingresar los datos de los padres con el primer hijo, as&iacute;, no tendr&aacute; que volver a introducirlos</cellbytelabel>.
                    </td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="23">Diagn&oacute;sticos</cellbytelabel>:</td>
					<td colspan="3"><%=fb.textarea("diagnostico_bb",cdo.getColValue("diagnostico_bb"), false, false,viewMode, 50, 2,2000, "", "", "")%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="24">Observaci&oacute;n</cellbytelabel>:</td>
					<td colspan="3"><%=fb.textarea("observacion",cdo.getColValue("observacion"), false, false,viewMode, 50, 2,2000, "", "", "")%></td>
			</tr>
            
            </table></td></tr>
            
            <tr>
                <td colspan="6">
                   <table width="100%" cellpadding="0" cellspacing="0" >
                      <tr class="TextHeader" onClick="_showHide(1);" style="cursor:pointer; height:20px;">
                        <td colspan="5">&nbsp;<cellbytelabel id="25">DATOS DE LA MADRE</cellbytelabel></td><td align="right">[<span id="_mas1"><%=(id.trim().equals("0")?"-":"+")%></span>]&nbsp;</td>
                     </tr>
                   </table>
                </td>
           </tr>
            
            <tr id="_datos1" <%=(id.trim().equals("0")?"style=\"display:block;\"":"style=\"display:none;\"")%>>
               <td colspan="6">
                     <table width="100%" cellpadding="1" cellspacing="1">
                     
                     <tr class="TextRow02">
				        <td colspan="6">&nbsp;</td>
			         </tr>

	

			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="26">Nombre</cellbytelabel>:</td>
				    <td colspan="5"><%=fb.textBox("nombre_madre",cdo.getColValue("nombre_madre"),true,false,viewMode,60,100)%></td>
            </tr>
			<tr class="TextRow01">
					<td align="right">Edad:</td>
					<td>
				      <%=fb.textBox("edad_madre",cdo.getColValue("edad_madre"),false,false,viewMode,5,3)%></td>
					<td colspan="4"><cellbytelabel id="27">G(Embarazo)</cellbytelabel>:<%=fb.textBox("g",(id.equals("00")||id.equals("0")?cdoP.getColValue("g"):cdo.getColValue("g")),false,false,viewMode,5,2)%> <cellbytelabel id="28">P(Parto)</cellbytelabel>:<%=fb.textBox("p",(id.equals("00")||id.equals("0")?cdoP.getColValue("p"):cdo.getColValue("p")),false,false,viewMode,5,2)%>
						<cellbytelabel id="29">C(Ces&aacute;rea)</cellbytelabel>:<%=fb.textBox("c",(id.equals("00")||id.equals("0")?cdoP.getColValue("c"):cdo.getColValue("c")),false,false,viewMode,5,2)%>
						<cellbytelabel id="30">A(Aborto)</cellbytelabel>:<%=fb.textBox("a",(id.equals("00")||id.equals("0")?cdoP.getColValue("a"):cdo.getColValue("a")),false,false,viewMode,5,2)%>					</td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="31">Ginecol&oacute;go</cellbytelabel>:</td>
					<td colspan="5"><%=fb.textBox("ginecologo",(id.equals("00")||id.equals("0")?cdoP.getColValue("ginecologo"):cdo.getColValue("ginecologo")),false,false,viewMode,15,null,null,"onBlur=\"javascript:getMedicDetail(this.value,'adm')\"")%>
								<%=fb.textBox("nombreGinecologo",(id.equals("00")||id.equals("0")?cdoP.getColValue("nombreGinecologo"):cdo.getColValue("nombreGinecologo")),false,false,true,50)%><%=fb.button("btnGinecolo","...",false,viewMode,null,null,"onClick=\"javascript:showMedicoList('ginecologo')\"")%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="32">Diagn&oacute;stico</cellbytelabel>:</td>
					<td colspan="5"><%=fb.textarea("diagnostico_mama",(id.equals("00")||id.equals("0")?cdoP.getColValue("diagnostico_mama"):cdo.getColValue("diagnostico_mama")), false, false,viewMode, 50, 2,2000, "", "", "")%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="33">Fiebre</cellbytelabel>:</td>
					
					<td><%=fb.select("fiebre","N=NO,S=SI",(id.equals("00")||id.equals("0")?cdoP.getColValue("fiebre"):cdo.getColValue("fiebre")),false,viewMode,0,null,null,"onchange=\"ctrlFever(this.value)\"",null,"N")%></td>
					<td colspan="4">Valor:<%=fb.decBox("valor_fiebre",(id.equals("00")||id.equals("0")?cdoP.getColValue("valor_fiebre"):cdo.getColValue("valor_fiebre")),false,false,true,10,5.2)%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="34">Tipo Parto</cellbytelabel>:</td>
					<td colspan="5"><%=fb.select("tipo_parto","C=CESAREA,P=PARTO",(id.equals("00")||id.equals("0")?cdoP.getColValue("tipo_parto"):cdo.getColValue("tipo_parto")),false,viewMode,0,"S")%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="24">Observaci&oacute;n</cellbytelabel>:</td>
					<td colspan="5"><%=fb.textarea("observacion_mama",(id.equals("00")||id.equals("0")?cdoP.getColValue("observacion_mama"):cdo.getColValue("observacion_mama")), false, false,viewMode, 50, 2,2000, "", "", "")%></td>
			</tr>
		   </table>
               </td>
            </tr>
            
			  <tr>
                <td colspan="6">
                   <table width="100%" cellpadding="0" cellspacing="0" >
                      <tr class="TextHeader" onClick="_showHide(2);" style="cursor:pointer; height:20px;">
                        <td colspan="5">&nbsp;DATOS DEL PADRE</td><td align="right">[<span id="_mas2"><%=(id.trim().equals("0")?"-":"+")%></span>]&nbsp;</td>
                     </tr>
                   </table>
                </td>
           </tr>
                       
            <tr id="_datos2" <%=(id.trim().equals("0")?"style=\"display:block;\"":"style=\"display:none;\"")%>>
                <td colspan="6">
                    <table width="100%" cellpadding="1" cellspacing="1">
                    
			<tr class="TextRow01">
					<td align="right" width="20%">Se dieron Datos del Padre:</td>
					<td width="80%"><%=fb.select("sin_datos","S=SI,N=NO",(id.equals("00")||id.equals("0")?cdoP.getColValue("sin_datos"):cdo.getColValue("sin_datos")),false,viewMode,0,null,null,"S")%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="2">Nombre</cellbytelabel>:</td>
				  <td><%=fb.textBox("nombre_padre",(id.equals("00")||id.equals("0")?cdoP.getColValue("nombre_padre"):cdo.getColValue("nombre_padre")),false,false,viewMode,30,100)%>			</tr>
			<tr class="TextRow01">
					<td align="right">Dirección:</td>
					<td><%=fb.textBox("dir_padre",(id.equals("00")||id.equals("0")?cdoP.getColValue("dir_padre"):cdo.getColValue("dir_padre")),false,false,viewMode,50,100)%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right">Edad:</td>
				  <td><%=fb.textBox("edad_padre",(id.equals("00")||id.equals("0")?cdoP.getColValue("edad_padre"):cdo.getColValue("edad_padre")),false,false,viewMode,5,2)%>			</tr>
			<tr class="TextRow01">
					<td align="right">Telefono:</td>
				  <td><%=fb.textBox("tel_padre",(id.equals("00")||id.equals("0")?cdoP.getColValue("tel_padre"):cdo.getColValue("tel_padre")),false,false,viewMode,15,11)%>			</tr>
			
                    </table>
                
                </td>
            </tr>
            
            <tr  class="TextRow02">&nbsp;</tr>
            <tr class="TextHeader02">
					<td colspan="6"><cellbytelabel id="35">AUDITOR&Iacute;A</cellbytelabel></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="36">Creado Por</cellbytelabel>:</td>
					<td colspan="5"><%=fb.textBox("usuario_crea",cdo.getColValue("usuario_crea"),false,false,true,30)%>
					<%=fb.textBox("fecha_crea",cdo.getColValue("fecha_crea"),false,false,true,30)%></td>
			</tr>
			<tr class="TextRow01">
					<td align="right"><cellbytelabel id="37">Modificado Por</cellbytelabel>:</td>
					<td colspan="5"><%=fb.textBox("usuario_mod",cdo.getColValue("usuario_mod"),false,false,true,30)%>
					<%=fb.textBox("fecha_mod",cdo.getColValue("fecha_mod"),false,false,true,30)%></td>
			</tr>
            
			
			<%
	fb.appendJsValidation("if(error>0)setHeight();");
%>
		<!-- //////////////////////////////////////////////////////////////////////////////////////////////////////////// -->
			<tr  class="TextRow02">
			<td align="right" colspan="6">
				<cellbytelabel id="38">Opciones de Guardar</cellbytelabel>:
				<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro-->
				<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="40">Mantener Abierto</cellbytelabel>
				<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="41">Cerrar</cellbytelabel>
				<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
				<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>			</td>
			</tr>
<%=fb.formEnd(true)%>
</table>
<!-- TAB0 DIV END HERE-->
</div>


<!-- MAIN DIV END HERE -->
</div>
					</td>
				</tr>
			</table>

</td>
</tr>
</table>
</body>
</html>
<%
}//GET
else
{

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	//if (tab.equals("0")) //Liquidos administrados
	//{
		

			cdo = new CommonDataObject();

			cdo.setTableName("tbl_adm_neonato");
			
			//cdo.addColValue("tipo_servicio",request.getParameter("tipoServicio"+i));
			//cdo.addColValue("centro_servicio",id);
			cdo.setWhereClause("admsec_madre="+noAdmision+"  /* and pac_id_madre = "+pacId+"*/ and fnac_madre = to_date('"+dob+"','dd/mm/yyyy')  and codpac_madre = "+codPac);
			 cdo.addColValue("fecha_nacimiento",request.getParameter("fecha_nacimiento"));
			 cdo.addColValue("hora_nacimiento",request.getParameter("hora_nacimiento"));
			//cdo.addColValue("codigo_paciente",request.getParameter("codigo_paciente"));
			cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("sexo",request.getParameter("sexo"));
			cdo.addColValue("peso_lb",request.getParameter("peso_lb"));
			cdo.addColValue("peso_onz",request.getParameter("peso_onz"));
			cdo.addColValue("talla",request.getParameter("talla"));			
			
			cdo.addColValue("usuario_mod",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_mod","sysdate");
			cdo.addColValue("nombre_bb",request.getParameter("nombre_bb"));
			
			cdo.addColValue("medicamentos",request.getParameter("medicamentos"));
			cdo.addColValue("presentacion",request.getParameter("presentacion"));
			cdo.addColValue("pediatra",request.getParameter("pediatra"));
			cdo.addColValue("liquido_amniotico",request.getParameter("liquido_amniotico"));
			
			cdo.addColValue("apgar1",request.getParameter("apgar1"));
			cdo.addColValue("apgar5",request.getParameter("apgar5"));
			cdo.addColValue("vivo_sano",request.getParameter("vivo_sano"));
			cdo.addColValue("semanas_gestacion",request.getParameter("semanas_gestacion"));
			cdo.addColValue("diagnostico_bb",request.getParameter("diagnostico_bb"));
			cdo.addColValue("observacion",request.getParameter("observacion"));
			
			cdo.addColValue("fnac_madre",dob);
			cdo.addColValue("codpac_madre",codPac);
			cdo.addColValue("admsec_madre",noAdmision);
    		cdo.addColValue("pac_id_madre",request.getParameter("pacId"));
			cdo.addColValue("origen_reg","EXP");
	
			
			if(request.getParameter("id") == null || request.getParameter("id").equals("")||request.getParameter("id").equals("0") ||request.getParameter("id").equals("00"))
			{
				cdo.setAutoIncCol("secuencia");
				//cdo.addPkColValue("secuencia","");
				cdo.setAutoIncWhereClause("admsec_madre="+noAdmision+"  /* and pac_id_madre = "+pacId+"*/ and fnac_madre = to_date('"+dob+"','dd/mm/yyyy') and codpac_madre = "+codPac);
				
				cdo.addPkColValue("secuencia","");

				cdo.addColValue("usuario_crea",(String) session.getAttribute("_userName"));
				cdo.addColValue("fecha_crea","sysdate");
			
			}else{ //cdo.addColValue("secuencia",request.getParameter("id"));
			    cdo.setWhereClause("admsec_madre="+noAdmision+"  /* and pac_id_madre = "+pacId+"*/ and fnac_madre = to_date('"+dob+"','dd/mm/yyyy') and codpac_madre = "+codPac+" and secuencia = "+request.getParameter("id"));
				id = request.getParameter("id");
				}
			
		/*if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			if (mode.equalsIgnoreCase("add"))
			{
				SQLMgr.insert(cdo);
				id = SQLMgr.getPkColValue("secuencia");
			}
			else{ SQLMgr.update(cdo);}
			
			ConMgr.clearAppCtx(null);
		}*/

	//}
	//else if (tab.equals("1")) //Datos Madre
	//{
		/*and secuencia ="+request.getParameter("id")*/
		//cdo.setTableName("tbl_adm_neonato");
		//cdo.setWhereClause("admsec_madre="+noAdmision+"  /* and pac_id_madre = "+pacId+"*/ and fnac_madre = to_date('"+dob+"','dd/mm/yyyy') and codpac_madre = "+codPac);
				
		//M A D R E
	   cdo.addColValue("nombre_madre",request.getParameter("nombre_madre"));
	   cdo.addColValue("edad_madre",request.getParameter("edad_madre"));
	   cdo.addColValue("ginecologo",request.getParameter("ginecologo"));
	   cdo.addColValue("diagnostico_mama",request.getParameter("diagnostico_mama"));
	   cdo.addColValue("fiebre",request.getParameter("fiebre"));
	   cdo.addColValue("valor_fiebre",request.getParameter("valor_fiebre"));
	   cdo.addColValue("observacion_mama",request.getParameter("observacion_mama"));
	   cdo.addColValue("g",request.getParameter("g"));
	   cdo.addColValue("p",request.getParameter("p"));
	   cdo.addColValue("c",request.getParameter("c"));
	   cdo.addColValue("a",request.getParameter("a"));	
	   cdo.addColValue("tipo_parto",request.getParameter("tipo_parto"));
     
			
		/*if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			if (mode.equalsIgnoreCase("add"))SQLMgr.insert(cdo);
			else SQLMgr.update(cdo);
			ConMgr.clearAppCtx(null);
		}*/
	//}
	//else if (tab.equals("2")) //Datos Padre
	//{
		//+" and secuencia ="+request.getParameter("id")
		//cdo = new CommonDataObject();

		//cdo.setTableName("tbl_adm_neonato");
		//cdo.setWhereClause("admsec_madre="+noAdmision+"  /* and pac_id_madre = "+pacId+"*/ and fnac_madre = to_date('"+dob+"','dd/mm/yyyy') and codpac_madre = "+codPac);
			
	
		//P A D R E
		cdo.addColValue("nombre_padre",request.getParameter("nombre_padre"));
		cdo.addColValue("edad_padre",request.getParameter("edad_padre"));
		cdo.addColValue("tel_padre",request.getParameter("tel_padre"));
		cdo.addColValue("dir_padre",request.getParameter("dir_padre"));
		
		cdo.addColValue("sin_datos",request.getParameter("sin_datos"));
		
/*		if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			if (mode.equalsIgnoreCase("add"))SQLMgr.insert(cdo);
			else SQLMgr.update(cdo);
			ConMgr.clearAppCtx(null);
		}*/
	//}

if (baction.equalsIgnoreCase("Guardar"))
		{
			ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
			if (mode.equalsIgnoreCase("add"))
			{
				SQLMgr.insert(cdo);
				id = SQLMgr.getPkColValue("secuencia");
			}
			else{ SQLMgr.update(cdo);}
			
			ConMgr.clearAppCtx(null);
		}
%>
<html>
<head>

<script language="javascript">
function closeWindow()
{
	var clientIdentifier = '<%=ConMgr.getClientIdentifier()%>';
	var context = '<%=request.getContextPath()%>';	
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
    
	alert('<%=SQLMgr.getErrMsg()%>');
	// No esta guardando el pac_id_madre en admisión,
	// y necesitamos ese para buscar el pac_id y la secuencia del bebé
	// pacId = pacId&noAdmision=noAdmision&cds=cds

	//var msg = getMsg(context,clientIdentifier);
    /*abrir_ventana1('../admision/print_admision_barcode.jsp?pacId=&noAdmision=&cds=');

	var msg = getDBData(context, 'message', 'tbl_par_messages', 'client_identifier = \''+clientIdentifier+'\'','');
	
	if ( msg.substring(0,15).trim() == 'PRINT_BRAZALETE'){
		if(confirm('Se crearon el registro y la admisión del bebé.\nDesea usted imprimir el brazalete?')){
			//abrir_ventana('../admision/print_admision_barcode.jsp?pacId=&noAdmision=&cds=');
				alert('Other alert'+(23+32));
		}
	}else{
		alert('Se encontró un error al tratar de crear automaticamente registros de: paciente y admisión del bebé!\nPor favor contacte el administrador o créalos manualmente!');
	}*/
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/expediente/expediente_redirect.jsp"))
	{
%>
//window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/expediente/expediente_redirect.jsp")%>';
<%
	}
	else
	{
%>
//window.opener.location = '<%=request.getContextPath()%>/expediente/expediente_redirect.jsp';
<%
	}

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
} else throw new Exception(SQLMgr.getErrMsg());
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&mode=add&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&dob=<%=dob%>&codPac=<%=codPac%>&id=<%=id%>&cedPas=<%=cedula_madre%>';
}


function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?seccion=<%=seccion%>&tab=<%=tab%>&mode=add&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&dob=<%=dob%>&codPac=<%=codPac%>&id=<%=id%>&myMode=braz&cedPas=<%=cedula_madre%>';
}
</script>

</head>
<body onLoad="closeWindow()" class="TextRow01">
</body>
</html>
<%
}
%>