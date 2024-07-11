<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDoc" scope="session" class="java.util.Hashtable" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

int iconHeight = 24;
int iconWidth = 24;
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
ArrayList al = new ArrayList();
ArrayList al2 = new ArrayList();
ArrayList al3 = new ArrayList();
Admision adm = new Admision();
String key = "";
StringBuffer sbSql;
String sql = "";

Hashtable ht = null;
Hashtable iScan = new Hashtable();

String fp = "";
String fg = "";
String tab = "";
String mode = "";
String pacId = "";
String noAdmision = "";
String change = "";
String codigo = "";
String docId = "";
String docDesc = "";
String expStatus = "";
String hidePacHeader = "";
String exp = "";
int docLastLineNo = 0;

if (request.getContentType() != null && ((String)request.getContentType()).toLowerCase().startsWith("multipart"))
{

	ht = CmnMgr.getMultipartRequestParametersValue(request,java.util.ResourceBundle.getBundle("path").getString("scanned"),20,true);
	mode = (String) ht.get("mode");
	pacId = (String) ht.get("pacId");
	noAdmision = (String) ht.get("noAdmision");
	change = (String) ht.get("change");
	codigo = (String)ht.get("scanId");
	docId = (String) ht.get("docId");
	docDesc = (String)ht.get("docDesc");
	fp = (String)ht.get("fp");
	fg = (String)ht.get("fg");
	tab = (String)ht.get("tab");
	exp = (String)ht.get("exp");
	expStatus = (String)ht.get("expStatus");
	hidePacHeader = (String)ht.get("hidePacHeader");
	docLastLineNo = Integer.parseInt(((String)ht.get("docLastLineNo")));

}else{

	fp = request.getParameter("fp");
	fg = request.getParameter("fg");
 	tab = request.getParameter("tab");
 	mode = request.getParameter("mode");
 	pacId = request.getParameter("pacId");
    noAdmision = request.getParameter("noAdmision");
	change = request.getParameter("change");
	codigo = request.getParameter("scanId");
 	docId = request.getParameter("docId");
 	docDesc = request.getParameter("docDesc");
 	expStatus = request.getParameter("expStatus");
 	exp = request.getParameter("exp");
 	hidePacHeader = request.getParameter("hidePacHeader");
 	docLastLineNo = (request.getParameter("docLastLineNo")!=null?Integer.parseInt(request.getParameter("docLastLineNo")):0);
}

String fecha="",fechaIngreso="";

int prioridad = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
String estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA";
String contCredOptions = "C=CONTADO, R=CREDITO";

if (fg == null) fg = "";
if (fp == null) fp = "";
if (tab == null) tab = "0";
if (hidePacHeader == null) hidePacHeader = "";
boolean viewMode = false;
if (mode == null) mode = "add";
if (mode.equalsIgnoreCase("view") || fg.equalsIgnoreCase("con_sup")) { viewMode = true; estadoOptions = "A=ACTIVA,P=PRE-ADMISION,S=ESPECIAL,E=EN ESPERA,I=INACTIVA,C=CANCELADA,N=ANULADA"; contCredOptions = "C=CONTADO, R=CREDITO"; }


if (request.getMethod().equalsIgnoreCase("GET"))
{

  /* 	String dir = java.util.ResourceBundle.getBundle("path").getString("scanned")+"/";
	String folderPac = "paciente-"+pacId;
	String folderAdm = "admision-"+noAdmision;

	try {
	   if (CmnMgr.createFolderDos(dir,folderPac).equals("1")){
	         String pacFolder = dir+folderPac+"/";
	         CmnMgr.createFolderDos(pacFolder,folderAdm);
	   }
	}catch(Exception e){
	   System.out.println("Error creating the folder "+e);
	}
	*/

   //GETTING THE SCCANNING.....
	al2 = SQLMgr.getDataList("select e.codigo, e.docid docScanId, (SELECT nombre FROM TBL_ADM_DOCUMENTO WHERE codigo=e.docid) AS documentoDesc, decode(e.scanpath,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("scanned").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"), request.getContextPath())+"/'||e.scanpath) as scanPath, nvl(e.scanpath,'') title ,decode(e.scanpath,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("scanned")+"/'||e.scanpath) as filePath from TBL_ADM_DOC_ESCANEADO e WHERE e.pacid ="+pacId+" and e.secuencia = "+noAdmision+"");


	if (mode.equalsIgnoreCase("add"))
	{

		iDoc.clear();

		if (pacId == null || pacId.trim().equals("")) pacId = "0";
		else
		{
			sbSql = new StringBuffer();
			sbSql.append("select to_char(coalesce(f_nac, fecha_nacimiento),'dd/mm/yyyy') as fechaNacimiento, codigo as codigoPaciente, decode(provincia,null,' ',provincia) as provincia, nvl(sigla,' ') as sigla, decode(tomo,null,' ',tomo) as tomo, decode(asiento,null,' ',asiento) as asiento, nvl(d_cedula,' ') as dCedula, nvl(pasaporte,' ') as pasaporte, primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) as nombrePaciente, vip as key from tbl_adm_paciente where pac_id=");
			sbSql.append(pacId);
			Admision pac = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Admision.class);
            if (pac == null) pac = new Admision();

			adm.setFechaNacimiento(pac.getFechaNacimiento());
			adm.setCodigoPaciente(pac.getCodigoPaciente());
			adm.setProvincia(pac.getProvincia());
			adm.setSigla(pac.getSigla());
			adm.setTomo(pac.getTomo());
			adm.setAsiento(pac.getAsiento());
			adm.setDCedula(pac.getDCedula());
			adm.setPasaporte(pac.getPasaporte());
			adm.setNombrePaciente(pac.getNombrePaciente());
			adm.setKey(pac.getKey());
		}//else

		noAdmision = "0";
		adm.setPacId(pacId);
		adm.setNoAdmision(noAdmision);
		adm.setFechaIngreso(cDateTime.substring(0,10));
		adm.setAmPm(cDateTime.substring(11));
		adm.setFechaPreadmision("");
		adm.setEstado("A");
		adm.setTipoCta("P");


		}//if add
		else{

		if (pacId == null) throw new Exception("El Paciente no es válido. Por favor intente nuevamente!");
		if (noAdmision == null) throw new Exception("El No. Admisión no es válido. Por favor intente nuevamente!");

		sbSql = new StringBuffer();
		sbSql.append("select to_char(a.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento, a.codigo_paciente as codigoPaciente, a.secuencia as noAdmision, to_char(nvl(a.fecha_ingreso,sysdate),'dd/mm/yyyy') as fechaIngreso, decode(a.dias_estimados,null,' ',a.dias_estimados) as diasEstimados, a.estado, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy'),' ') as fechaEgreso, nvl(to_char(a.am_pm2,'hh12:mi am'),' ') as amPm2, a.dias_hospitalizados as diasHospitalizados, nvl(a.no_cuenta,'') as noCuenta, to_char(nvl(a.fecha_preadmision,sysdate),'dd/mm/yyyy hh12:mi am') as fechaPreadmision, a.categoria, a.tipo_admision as tipoAdmision, a.medico, a.usuario_creacion as usuarioCreacion, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, a.usuario_modifica as usuarioModifica, to_char(a.fecha_modifica,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.centro_servicio as centroServicio, to_char(nvl(a.am_pm,sysdate),'hh12:mi am') as amPm, nvl(a.tipo_cta,' ') as tipoCta, a.conta_cred as contaCred, coalesce(a.provincia,(select provincia from tbl_adm_paciente where pac_id=a.pac_id)) as provincia, coalesce(a.sigla,(select sigla from tbl_adm_paciente where pac_id=a.pac_id)) as sigla, coalesce(a.tomo,(select tomo from tbl_adm_paciente where pac_id=a.pac_id)) as tomo, coalesce(a.asiento,(select asiento from tbl_adm_paciente where pac_id=a.pac_id)) as asiento, coalesce(a.d_cedula,(select d_cedula from tbl_adm_paciente where pac_id=a.pac_id)) as dCedula, coalesce(a.pasaporte,(select pasaporte from tbl_adm_paciente where pac_id=a.pac_id)) as pasaporte, nvl(a.hosp_directa,' ') as hospDirecta, a.compania, nvl(a.medico_cabecera,' ') as medicoCabecera, a.pac_id as pacId, a.responsabilidad, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||decode(primer_apellido,null,'',' '||primer_apellido)||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_paciente where pac_id=a.pac_id) as nombrePaciente, (select descripcion from tbl_adm_categoria_admision where codigo=a.categoria) as categoriaDesc, (select descripcion from tbl_adm_tipo_admision_cia where categoria=a.categoria and codigo=a.tipo_admision and compania=a.compania) as tipoAdmisionDesc, (select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico) as nombreMedico, (select nvl(z.descripcion,'NO TIENE') from tbl_adm_medico x, tbl_adm_medico_especialidad y, tbl_adm_especialidad_medica z where x.codigo=a.medico and x.codigo=y.medico(+) and y.secuencia(+)=1 and y.especialidad=z.codigo(+)) as especialidad, coalesce((select primer_nombre||decode(segundo_nombre,null,'',' '||segundo_nombre)||' '||primer_apellido||decode(segundo_apellido,null,'',' '||segundo_apellido)||decode(sexo,'F',decode(apellido_de_casada,null,'',' '||apellido_de_casada)) from tbl_adm_medico where codigo=a.medico_cabecera),' ') as nombreMedicoCabecera, (select descripcion from tbl_cds_centro_servicio where codigo=a.centro_servicio) as centroServicioDesc,a.mes_cta_bolsa mesCtaBolsa ,(select to_char(f_nac,'dd/mm/yyyy') from vw_adm_paciente where pac_id=a.pac_id) as fechaNacimientoAnt from tbl_adm_admision a where a.pac_id=");
		sbSql.append(pacId);
		sbSql.append(" and a.secuencia=");
		sbSql.append(noAdmision);
		sbSql.append(" and a.compania=");
		sbSql.append(session.getAttribute("_companyId"));
		adm = (Admision) sbb.getSingleRowBean(ConMgr.getConnection(),sbSql.toString(),Admision.class);


if (change == null){
	iDoc.clear();
	sbSql = new StringBuffer();
			sbSql.append("select a.documento, a.revisado_admision as revisadoAdmision, to_char(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') as fechaCreacion, to_char(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') as fechaModifica, a.usuario_creacion as usuarioCreacion, a.usuario_modificacion as usuarioModifica, (select nombre from tbl_adm_documento where codigo=a.documento) as documentoDesc, a.revisado_sala as revisadoSala, a.revisado_fac as revisadoFac, a.revisado_cob as revisadoCob, a.observacion, a.estatus as estado, a.user_entrega as userEntrega, a.user_recibe as userRecibe, to_char(a.fecha_entrega,'dd/mm/yyyy') as fechaEntrega, to_char(a.fecha_recibe,'dd/mm/yyyy') as fechaRecibe, a.area_entrega as areaEntrega, a.area_recibe as areaRecibe, a.pase, a.pase_k as paseK from tbl_adm_documentos_admision a where a.pac_id=");
			sbSql.append(pacId);
			sbSql.append(" and a.admision=");
			sbSql.append(noAdmision);
			sbSql.append(" and exists (select null from tbl_adm_documento where codigo = a.documento and area_revision IN ('AD','AM')) order by a.fecha_creacion");


	/*sbSql.append("SELECT a.documento, a.revisado_admision AS revisadoAdmision, TO_CHAR(a.fecha_creacion,'dd/mm/yyyy hh24:mi:ss') AS fechaCreacion, TO_CHAR(a.fecha_modificacion,'dd/mm/yyyy hh24:mi:ss') AS fechaModifica, a.usuario_creacion AS usuarioCreacion, a.usuario_modificacion AS usuarioModifica, (SELECT nombre FROM TBL_ADM_DOCUMENTO WHERE codigo=a.documento) AS documentoDesc, a.revisado_sala AS revisadoSala, a.revisado_fac AS revisadoFac, a.revisado_cob AS revisadoCob, a.observacion, a.estatus AS estado, a.user_entrega AS userEntrega, a.user_recibe AS userRecibe, TO_CHAR(a.fecha_entrega,'dd/mm/yyyy') AS fechaEntrega, TO_CHAR(a.fecha_recibe,'dd/mm/yyyy') AS fechaRecibe, a.area_entrega AS areaEntrega, a.area_recibe AS areaRecibe, a.Pase, a.pase_k AS paseK, e.codigo, e.docid docScanId, decode(e.scanpath,null,' ','"+java.util.ResourceBundle.getBundle("path").getString("scanned").replaceAll(java.util.ResourceBundle.getBundle("path").getString("root"),"..")+"/'||e.scanpath) as scanPath  FROM TBL_ADM_DOCUMENTOS_ADMISION a, TBL_ADM_DOC_ESCANEADO e WHERE a.pac_id =");
sbSql.append(pacId);
sbSql.append(" and a.admision=");
sbSql.append(noAdmision);
sbSql.append(" and  e.docid(+) = a.documento");
sbSql.append(" order by 1");*/

			al  = SQLMgr.getDataList(sbSql.toString());

			docLastLineNo = al.size();
			for (int i=1; i<=al.size(); i++) {
				CommonDataObject obj = (CommonDataObject) al.get(i-1);
				obj.setKey(i);
				obj.setAction("U");

				try {
					iDoc.put(obj.getKey(), obj);
				} catch(Exception e) {
					System.err.println(e.getMessage());
				}
			}//for
	} //if change's null
	}//else
    
    if (expStatus!=null && expStatus.trim().equalsIgnoreCase("F")) viewMode = true;


al3 = SQLMgr.getDataList("SELECT DISTINCT a.documento, nvl(e.docid,-1) hasScan FROM TBL_ADM_DOCUMENTOS_ADMISION a, TBL_ADM_DOC_ESCANEADO e WHERE a.pac_id = "+pacId+" AND a.admision = "+noAdmision+" AND a.pac_id = e.pacid(+) and a.admision = e.secuencia(+) and e.docid(+) = a.documento");

for ( int s = 0; s<al3.size(); s++){
  CommonDataObject cdoS = new CommonDataObject();
  cdoS = (CommonDataObject)al3.get(s);
  iScan.put(cdoS.getColValue("documento"),cdoS.getColValue("hasScan"));
}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script>
document.title = 'Admisión - '+document.title;

function doAction(){
 <%if(exp!=null && exp.equals("")){%>newHeight();<%}%>
}

function eliminar(s, fileName)
{ 
	
    top.CBMSG.confirm('Confirma que desea eliminar el escaneado',{
      btnTxt:'Si,No',
      cb: function(r){
        if (r=="Si"){
           var _exe = executeDB('<%=request.getContextPath()%>','call SP_Eliminar_Escan_Doc_Adm('+s+')');
           if (_exe) {
             $.ajax({
                url: '../common/serve_dyn_content.jsp?serveTo=SCANNED_DOC&filePath='+fileName,
                cache: false,
                dataType: "html"
            }).done(function(data){
              if ($.trim(data) == "DELETED") window.location = '<%=request.getContextPath()+request.getServletPath()%>?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&mode=<%=mode%>&fp=<%=fp%>&fg=<%=fg%>&expStatus=<%=expStatus%>&hidePacHeader=<%=hidePacHeader%>';
              else CBMSG.warning(fileName + " no se ha borrado del disco!");
            }).fail(function(jqXHR, textStatus, errorThrown){
               if(jqXHR.status == 404 || errorThrown == 'Not Found'){ 
                  alert('Hubo un error 404, por favor contacte un administrador!'); 
               }else{
                  alert('Encontramos este error: '+errorThrown);
               }
            });	
           }
           else top.CBMSG.warning('Hubó un error al tratar de eliminar el documento, \nfavor de contactar el administrador del sistema!!!');
        }
      }
    });
}



var arrVal = new Array();

function getNewSelVal(opt){

 if(hasDBData('<%=request.getContextPath()%>','TBL_ADM_DOCUMENTOS_ADMISION','admision=\'<%=noAdmision%>\' and pac_id=\'<%=pacId%>\'','')){
   arrVal = splitRows(getDBData('<%=request.getContextPath()%>','documento','TBL_ADM_DOCUMENTOS_ADMISION','admision=\'<%=noAdmision%>\' and pac_id=\'<%=pacId%>\'',''));
 }
	var selBox = document.getElementById('docid'+opt);
	var selVal = selBox[selBox.selectedIndex].value;
	var found = 0;
	var len = 0;

	if ( arrVal == null ) {
	  arrVal.push(selVal);
	}else{

	   for ( s = 0; s<arrVal.length; s++ ){
	      if ( arrVal[s] == selVal ){
	      found++ ;
		  selBox.selectedIndex = "";
		  break;
	   }
	}

	if ( selBox ){
	  if ( found == 0 && selBox.selectedIndex != null ){
	 // CBMSG.warning("Found = "+found);
	     arrVal.push(selVal);
	  }
	}
}
	if ( found > 0 ){
	   top.CBMSG.warning("No se puede agregar el mismo documento dos veces para un paciente!");
	   document.getElementById("save").disabled = true;
	}else{document.getElementById("save").disabled = false;}

}


function show(h){
  var hidden = document.getElementById("lb_hidden"+h);
  var btn = document.getElementById("show_btn"+h);
  if(hidden){
      if(hidden.style.display=='none'){
	      hidden.style.display = '';
		  btn.style.display = 'none';
	  }else{hidden.style.display='none';
	      btn.style.display = '';
	  }
  }
}

function ctrlNullDoc(){
    var size = <%=iDoc.size()%>;

	for ( i = 1; i<=size; i++ ){

		 if (document.getElementById('docid'+i)){
			 var selBox = document.getElementById('docid'+i);
			 var selVal = selBox[selBox.selectedIndex].value;
			 if (selVal == ''){
				 top.CBMSG.warning("No se permite grabar un documento en blanco");
				 document.getElementById("save").disabled = true;
				 break;
			 }
		 }
    }
}
function ctrlDoc(){
    var size = <%=iDoc.size()%>;

	for ( i = 1; i<=size; i++ )
	{
		 var escaneado = document.getElementById('escaneado'+i).value;
		 if (escaneado !='')
		 {
			 if(escaneado.length - escaneado.lastIndexOf("\\")>58)
			 {
				top.CBMSG.warning('El documento '+escaneado.substring(escaneado.lastIndexOf("\\")+1)+' Tiene un nombre demasiado largo!');
				return false;
				break;
			 }

		 }
    }
	return true;
}

$(function(){
  $("#doc_hist").click(function(e){
    abrir_ventana('../admision/historial_documentos.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>');
  });
});
</script>
<script src="../js/iframe-resizer/iframeResizer.contentWindow.min.js"></script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<%if(!fg.trim().equalsIgnoreCase("admision") && !hidePacHeader.equals("1")){%>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="ADMISION"></jsp:param>
</jsp:include>
<%}%>

<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST,null,FormBean.MULTIPART);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("fg",fg)%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("expStatus",expStatus)%>
<%=fb.hidden("exp",exp)%>
<%=fb.hidden("hidePacHeader",hidePacHeader)%>
<%=fb.hidden("fechaNacimiento",adm.getFechaNacimiento())%>
<%=fb.hidden("codigoPaciente",adm.getCodigoPaciente())%>
<%=fb.hidden("pacId",adm.getPacId())%>
<%=fb.hidden("noAdmision",adm.getNoAdmision())%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("docSize",""+iDoc.size())%>
<%=fb.hidden("docLastLineNo",""+docLastLineNo)%>
<%fb.appendJsValidation("if(!ctrlDoc())error++;");%>
				<tr class="TextRow02">
					<td align="right">
            <%=fb.button("doc_hist","Historial",true,viewMode,null,"","","Ver historial de documentos")%>
					</td>
				</tr>
        <%if(!fg.trim().equalsIgnoreCase("admision") && !hidePacHeader.equals("1")){%>
				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;<cellbytelabel id="1">Admisi&oacute;n</cellbytelabel></td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextRow01">
							<td width="15%" align="right"><cellbytelabel id="2">Fecha de Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getFechaIngreso()%></td>
							<td width="15%" align="right"><cellbytelabel id="3">No. Admisi&oacute;n</cellbytelabel></td>
							<td width="35%"><%=adm.getNoAdmision()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="4">Fecha de Nacimiento</cellbytelabel></td>
							<td><%=adm.getFechaNacimientoAnt()%></td>
							<td align="right"><cellbytelabel id="5">No. Paciente</cellbytelabel></td>
							<td><%=adm.getCodigoPaciente()%></td>
						</tr>
						<tr class="TextRow01">
							<td align="right"><cellbytelabel id="6">Paciente</cellbytelabel></td>
							<td colspan="3">[<%=adm.getPacId()%>] <%=adm.getNombrePaciente()%></td>
						</tr>
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(31)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="75%">&nbsp;<cellbytelabel id="7">Documentos</cellbytelabel></td>
							<td width="20%">&nbsp;</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus31" style="display:none">+</label><label id="minus31">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
                <%}%>
				<tr id="panel31">
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="7%"><cellbytelabel id="8">C&oacute;digo</cellbytelabel></td>
							<td width="84%"><cellbytelabel id="9">Documento</cellbytelabel></td>
							<td width="7%"><cellbytelabel id="10">Verificado</cellbytelabel></td>
							<td width="2%"><%=fb.submit("addDocumento","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Documentos")%></td>
						</tr>
<%
al = CmnMgr.reverseRecords(iDoc);
String groupByDoc = "";
CommonDataObject cdo = new CommonDataObject();
String  disp = "";
String hidden = "";
boolean hasPic = false;

for (int i=1; i<=iDoc.size(); i++)
{
	key = al.get(i - 1).toString();
	CommonDataObject obj = (CommonDataObject) iDoc.get(key);
	String display = "";
	if (obj.getAction() != null && obj.getAction().equalsIgnoreCase("D")) display = " style=\"display:none\"";
%>
						<%=fb.hidden("key"+i,obj.getKey())%>
						<%=fb.hidden("iAction"+i,obj.getAction())%>
						<%=fb.hidden("remove"+i,"")%>
						<%=fb.hidden("documento"+i,obj.getColValue("Documento"))%>
						<%//fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value=='X'){ if(!ctrlRem("+i+")){CBMSG.warning('Ese documento tiene escaneado, por vafor elimínelo!'); document."+fb.getFormName()+".rem"+i+"disabled=true; return false;}}");%>

						<tr class="TextRow01"<%=display%>>
							<td><%=obj.getColValue("Documento")%></td>
							<td>
							<%=fb.select(ConMgr.getConnection(),"select codigo, nombre, area_revision as area from tbl_adm_documento where area_revision IN ('AD','AM')  order by nombre","docid"+i,obj.getColValue("Documento"),true,false,(viewMode),0,"Text10",null,"onchange=\"getNewSelVal("+i+")\"","","S")%>

						<%
							//
							if (iScan.get(obj.getColValue("Documento"))!= null && iScan.get(obj.getColValue("Documento")).equals(obj.getColValue("Documento"))){
							   	disp = "style=\"display:none;\"";
								hasPic = true;
								hidden = obj.getColValue("Documento");
							}else{
							   disp = "style=\"display:'';\"";
							   hasPic = false;
							   hidden = "";
							}
						%>
						<%=fb.hidden("has_pic"+i,""+hasPic)%>
						<%=(hasPic?fb.button("show_btn"+hidden,"+",true,viewMode,null,"","onClick=\"show('"+hidden+"')\"","Agregar mas imágenes"):"")%>
					    <span id="lb_hidden<%=hidden%>" <%=disp%>>&nbsp;&nbsp;&nbsp;<cellbytelabel id="11">Escaneado</cellbytelabel><%=fb.fileBox("escaneado"+i,"",false,false,15,"","","")%></span>
			<%
				if ( al2.size() > 0 ){
					for ( int s = 0; s<al2.size(); s++){
					  cdo = (CommonDataObject)al2.get(s);

					    /*String fileTitle = "";
  						String[] fileTitleTmp;
   						int dot;

						fileTitle = cdo.getColValue("scanpath");
      					try {
	  						 fileTitleTmp = fileTitle.split("_");
	   						 dot = fileTitleTmp[1].lastIndexOf(".");

	   						 if ( dot > 0 ){
		 					     fileTitleTmp[1] = fileTitleTmp[1].substring(0,dot);
	   					     }
      					}catch(Exception e){
	  				      fileTitleTmp = fileTitle.split("_");
      		            }*/

					  if (cdo.getColValue("docScanId").equals(obj.getColValue("Documento"))){
					  %>
					     <img src="../images/search.gif" id="scan<%=i%>" width="20" height="20" onClick="javascript:abrir_ventana('<%=cdo.getColValue("scanPath")%>')" style="cursor:pointer; display:inline; vertical-align:middle;" title="<%=cdo.getColValue("title")%>"/>&nbsp;&nbsp;<%=cdo.getColValue("title")%>&nbsp;&nbsp;<a href="javascript:eliminar(<%=cdo.getColValue("codigo")%>,'<%=cdo.getColValue("filePath")%>')"  class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')" title="Eliminar: <%=cdo.getColValue("title")%>">X</a>&nbsp;&nbsp;


			<%
			} //group by docid
			} //for s
			} //if al2.size() > 0
			%>


							</td>
							<td align="center"><%=fb.checkbox("revisadoAdmision"+i,"S",(obj.getColValue("RevisadoAdmision") != null && obj.getColValue("RevisadoAdmision").equalsIgnoreCase("S")),viewMode)%></td>
<td align="center">
<%=fb.submit("rem"+i,"X",true,hasPic,null,"cursor:pointer","onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\" ",(hasPic?"Por favor elimina primero el escaneado!":"Eliminar Documento"))%></td>
						</tr>

<%
}//for


%>
						</table>
					</td>
				</tr>

				<tr class="TextRow01">
					<td align="right">
						<cellbytelabel id="12">Opciones de Guardar</cellbytelabel>:
						<!--<%=fb.radio("saveOption","N",false,viewMode,false)%>Crear Otro -->
						<%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="13">Mantener Abierto</cellbytelabel>
						<%if(fp!=null && !fp.equals("expediente")){%>
						<%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="14">Cerrar</cellbytelabel>
						<%}%>
						<%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"ctrlNullDoc(); setBAction('"+fb.getFormName()+"',this.value)\"; onmouseover=\"\"")%>
						<%if(fp!=null && !fp.equals("expediente")){%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.parent.close()\"")%>
						<%}%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

</body>
</html>
<%
} //get

else{
	String saveOption = (String)ht.get("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = (String)ht.get("baction");
	String errCode = "";
	String errMsg = "";

	int size = 0;
	if ( ((String)ht.get("docSize")) != null) size = Integer.parseInt(((String)ht.get("docSize")));
	String itemRemoved = "";

	al.clear();
	iDoc.clear();
	for (int i=1; i<=size; i++) {
		CommonDataObject obj = new CommonDataObject();

		obj.setKey(i);
		obj.setAction((String)ht.get("iAction"+i));
		obj.setTableName("tbl_adm_documentos_admision");
		obj.addColValue("documento",(String)ht.get("docid"+i));
		obj.setWhereClause("pac_id = "+pacId+" and admision = "+noAdmision+" and documento = "+obj.getColValue("documento"));

		if (obj.getAction().equalsIgnoreCase("I")) {
			obj.addColValue("pac_id",(String)ht.get("pacId"));
			obj.addColValue("admision",(String)ht.get("noAdmision"));
			obj.addColValue("fecha_nacimiento",(String)ht.get("fechaNacimiento"));
			obj.addColValue("paciente",(String)ht.get("codigoPaciente"));
			obj.addColValue("usuario_creacion",(String)session.getAttribute("_userName"));
			obj.addColValue("fecha_creacion","sysdate");
		}
		obj.addColValue("usuario_modificacion",(String)session.getAttribute("_userName"));
		obj.addColValue("fecha_modificacion","sysdate");
		if ((String)ht.get("revisadoAdmision"+i) != null && ((String)ht.get("revisadoAdmision"+i)).equalsIgnoreCase("S")) {
			obj.addColValue("RevisadoAdmision","S");
			obj.addColValue("Revisado_Admision","S");
		} else {
			obj.addColValue("RevisadoAdmision","N");
			obj.addColValue("Revisado_Admision","N");
		}

		if ((String)ht.get("remove"+i) != null && !((String)ht.get("remove"+i)).equals("")) {
			itemRemoved = obj.getKey();
			if (obj.getAction().equalsIgnoreCase("I")) obj.setAction("X");
			else obj.setAction("D");
		}

		if (!obj.getAction().equalsIgnoreCase("X")) {
			try {
				iDoc.put(obj.getKey(),obj);
				al.add(obj);
			} catch(Exception e) {
				System.err.println(e.getMessage());
			}
		}
	}

	if (!itemRemoved.equals("")) {
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&docLastLineNo="+docLastLineNo+"&fp="+fp+"&fg="+fg+"&expStatus="+expStatus+"&hidePacHeader="+hidePacHeader+"&exp="+exp);
		return;
	}

	if (baction != null && baction.equals("+")) {

		CommonDataObject obj = new CommonDataObject();
		obj.setAction("I");
		obj.setKey(iDoc.size() + 1);
		obj.addColValue("documento","");

		try {
			iDoc.put(obj.getKey(),obj);
		} catch (Exception e) {
			System.err.println(e.getMessage());
		}

		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=3&type=1&mode="+mode+"&pacId="+pacId+"&noAdmision="+noAdmision+"&docLastLineNo="+docLastLineNo+"&fp="+fp+"&fg="+fg+"&expStatus="+expStatus+"&hidePacHeader="+hidePacHeader+"&exp="+exp);
		return;
	}

	if ( baction.equals("Guardar") ){

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();



   /* #########################################################*
	* CREAMOS LAS CARPETAS: CARPETA_EN_EL_SERVIDOR_DE_IMAGENES/paciente-pacId/admision-noAdmision
	* #########################################################*/
if ( errCode.equals("1") ){

	//System.out.println(" [[[[[[[[[[[[[[[[[[[[[[[[ SCAN ID "+(String)ht.get("escaneado1") );
	ArrayList alScan = new ArrayList();


   for ( int s = 1; s<=size; s++ ){

      CommonDataObject cdoScan = new CommonDataObject();

	  // ((String)ht.get("escaneado")) != null ||

	  if (!((String)ht.get("escaneado"+s)).equals("") ){

	  String docPath = "";

      cdoScan.setTableName("tbl_adm_doc_escaneado");
	  //cdoScan.setWhereClause("pacid="+pacId+" and secuencia="+noAdmision);
      cdoScan.setAutoIncCol("codigo");
 	  cdoScan.addColValue("pacid",(String)ht.get("pacId"));
	  cdoScan.addColValue("secuencia",(String)ht.get("noAdmision"));

	  docPath = (String)ht.get("escaneado"+s);
	  docPath = CmnMgr.cleanFile(docPath);
	  //docPath = Normalizer.normalize(docPath, Normalizer.Form.NFD).replaceAll("[^\\p{ASCII}]", "");

	  System.out.println(":thebrain :::::::::::::::::::::::::::"+docPath);
      cdoScan.addColValue("docid",(String)ht.get("docid"+s));
	  cdoScan.addColValue("scanpath",docPath);

	  alScan.add(cdoScan);
	  }//if not null

   }//for s


   if ( alScan.size() == 0 ){
       CommonDataObject cdoScan = new CommonDataObject();
	   cdoScan.setTableName("tbl_adm_doc_escaneado");
	   //cdoScan.setWhereClause("pacid="+pacId+" and secuencia="+noAdmision);
	   cdoScan.setWhereClause("codigo=-1");
	   //cdoScan.setAutoIncCol("codigo");
	   alScan.add(cdoScan);
   }

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.insertList(alScan,true,false);
		ConMgr.clearAppCtx(null);
		errCode = SQLMgr.getErrCode();
		errMsg = SQLMgr.getErrMsg();

  }//IF ERROR CODE IS 1 (SUCCESFUL)

 }//if guardar
%>
<html>
<head>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?fg=<%=fg%>&mode=edit&tab=<%=tab%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>&expStatus=<%=expStatus%>&hidePacHeader=<%=hidePacHeader%>&exp=<%=exp%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//post
%>