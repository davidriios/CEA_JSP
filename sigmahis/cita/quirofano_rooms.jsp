<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="java.util.Vector"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr"/>
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr"/>
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail"/>
<jsp:useBean id="CmnMgr" scope="page"	class="issi.admin.CommonMgr"/>
<jsp:useBean id="SQLMgr" scope="page"	class="issi.admin.SQLMgr"/>
<jsp:useBean id="fb" scope="page"	class="issi.admin.FormBean"/>
<%
/**
==========================================================================================================================
FORMA				MENU																														NOMBRE EN FORMA
CDC100100		CITAS\TRANSACCIONES\CRONOGRAMA DE QUIROFANOS		SALON DE OPERACIONES PROGRAMA QUIRURGICO
==========================================================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted est� fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);



int nCol = 0;//CmnMgr.getCount("select count(*) from tbl_sal_habitacion where quirofano!=1");
int colWidth = 270;
ArrayList al = new ArrayList();
String sql = "";
String fechaCita = request.getParameter("fechaCita");
String citasSopAdm = request.getParameter("citasSopAdm")==null?"":request.getParameter("citasSopAdm");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String nombreMedico = request.getParameter("nombreMedico");
String codMedico = request.getParameter("codMedico"); 
String provincia = request.getParameter("provincia");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String dCedula = request.getParameter("dCedula");
String pasaporte = request.getParameter("pasaporte");
String tipoPaciente = request.getParameter("tipoPaciente");
String fechaNacimiento = request.getParameter("fechaNacimiento");
String codigoPaciente = request.getParameter("codigoPaciente");
String sexo = request.getParameter("sexo");
String fg = "SO";
if(request.getParameter("fg")!=null) fg = request.getParameter("fg");
if (pacId == null) pacId = "";
if (noAdmision == null) noAdmision = "";
if (sexo == null) sexo = "";
if (sigla == null) sigla = "";
if (provincia == null) provincia = "";
if (tomo == null) tomo = "";
if (asiento == null) asiento = "";
StringBuffer sbSql= new StringBuffer();
if (request.getMethod().equalsIgnoreCase("GET"))
{
	sbSql.append("select codigo, descripcion ,nvl(centro_servicio,unidad_admin) as cds from tbl_sal_habitacion h where compania = ");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and quirofano = 2 and nvl(centro_servicio,unidad_admin) in (select codigo from tbl_cds_centro_servicio where flag_cds in ('SOP','HEM','ENDO'))");
	
				if(!UserDet.getUserProfile().contains("0"))
				{
					sbSql.append(" and exists ( select null from tbl_sec_user_quirofano x where x.habitacion = codigo and x.compania=h.compania and x.user_id=");
						 
					sbSql.append(UserDet.getUserId());
					sbSql.append(")");
				} 
				sbSql.append("    order by codigo ");
				 
	al = SQLMgr.getDataList(sbSql);
	nCol = al.size();
	Hashtable htQ = new Hashtable();
	for(int i=0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject) al.get(i);
		htQ.put(""+(i+1), cdo);
	}
	sbSql= new StringBuffer();
	sbSql.append("select c.habitacion as nCol, c.habitacion as chkQ, sh.compania compania, sh.codigo habitacion, REPLACE(c.nombre_paciente, '''', '') as nombre_paciente, (select pp.apartado_postal from tbl_adm_paciente pp where pac_id = c.pac_id and rownum=1) cod_referencia, c.codigo, to_char(c.fecha_registro,'dd/mm/yyyy') as fecha_registro, to_char(c.hora_cita,'HH12:MI AM') as hora_inicio, c.hora_est as tiempo_hora, c.min_est as tiempo_min, nvl(c.observacion,'NO DEFINIDO') as observacion, substr(c.persona_reserva,0,15)||'.' persona_reserva, to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'HH12:MI AM') as hora_final, to_date(to_char(c.fecha_cita,'DD-MM-YYYY'),'DD-MM-YYYY') as fecha_inicio, to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'DD-MM-YYYY'),'DD-MM-YYYY') as fecha_final, to_date(to_char(c.fecha_cita,'DD-MM-YYYY')||' '||to_char(c.hora_cita,'HH24:MI'),'DD-MM-YYYY HH24:MI') as fecha_hora_inicio,NVL ( nvl((select (select SUBSTR (nvl(observacion, descripcion), 1, 20) from tbl_cds_procedimiento where codigo = z.procedimiento)  FROM tbl_cdc_cita_procedimiento z WHERE z.cod_cita = c.codigo  and z.fecha_cita = c.fecha_registro  AND codigo = (SELECT min(codigo) FROM tbl_cdc_cita_procedimiento  WHERE  cod_cita = c.codigo  AND fecha_cita = c.fecha_registro)), 'NO DEFINIDO'),c.observacion)desc_procedimiento,nvl((select (select 'Dr. '||substr(primer_nombre,1,1)||'. '||primer_apellido from tbl_adm_medico where codigo=z.medico) from tbl_cdc_personal_cita z where z.cod_cita=c.codigo and z.fecha_cita=c.fecha_registro and z.funcion=1  and rownum =1), nvl((select 'Dr. '||substr(primer_nombre,1,1)||'. '||primer_apellido from tbl_adm_medico where codigo=c.cod_medico and rownum = 1), ' ') ) as nombre_medico,c.pac_id,c.admision,nvl(sh.centro_servicio,sh.unidad_admin) as cds ,to_char(c.fec_nacimiento,'dd/mm/yyyy')dob,c.cod_paciente codPac, c.estado_cita, c.xtra1, to_char(c.fecha_cita,'dd/mm/yyyy') fecha_cita, to_char(c.hora_cita,'hh12:mi am') hora_cita, c.hora_est, c.min_est ,get_sec_comp_param(sh.compania,'CDC_CITA_TIPO_LABEL') as tipoLabel,get_sec_comp_param(sh.compania,'CDC_CITA_OCULTAR_HORA') as ocultarHora,");
    sbSql.append(" NOMBRE_ANESTESIOLOGO (c.codigo,c.fecha_registro)nombre_anestesiologo from tbl_sal_habitacion sh, tbl_cdc_cita c where sh.compania=");
	sbSql.append(session.getAttribute("_companyId"));
	sbSql.append(" and sh.codigo=c.habitacion AND sh.quirofano =2 and c.estado_cita not in ('C','T') and (to_date(to_char(c.fecha_cita,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('");
	sbSql.append(fechaCita);
	sbSql.append("','dd/mm/yyyy') or to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'dd/mm/yyyy'),'dd/mm/yyyy')=to_date('");
	sbSql.append(fechaCita);
	sbSql.append("','dd/mm/yyyy'))");
		if(!UserDet.getUserProfile().contains("0"))
		{
			sbSql.append(" and exists ( select null from tbl_sec_user_quirofano x where x.habitacion = sh.codigo and x.compania=sh.compania and x.user_id=");
				 
			sbSql.append(UserDet.getUserId());
			sbSql.append(")");
		}
	sbSql.append(" order by c.habitacion, sh.codigo, to_date(to_char(c.fecha_cita,'dd/mm/yyyy'),'dd/mm/yyyy'), to_char(c.hora_cita,'HH24:MI'), to_date(to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'dd/mm/yyyy'),'dd/mm/yyyy'), to_char((c.hora_cita + (trunc(round((c.hora_est + c.min_est / 60) * 60, 0), 0) / 60 / 24)),'HH24:MI')");
	al = SQLMgr.getDataList(sbSql);
	ArrayList alGen = new ArrayList();
	Hashtable htGen = new Hashtable();
	String codHab = "";
	for(int i =0; i<al.size(); i++){
		CommonDataObject cdo = (CommonDataObject)  al.get(i);
		
		if(!cdo.getColValue("nCol").equals(codHab)) alGen = new ArrayList();

		alGen.add(cdo);
	 	htGen.put(cdo.getColValue("nCol"), alGen);
		
		codHab = cdo.getColValue("nCol");
	}
	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
function editar(codigo, fecha){abrir_ventana('../cita/edit_cita.jsp?mode=edit&citasSopAdm=<%=citasSopAdm%>&codCita='+codigo+'&fechaCita='+fecha);}
function trasladar(codigo, fecha){abrir_ventana('../cita/edit_cita.jsp?mode=edit&citasSopAdm=<%=citasSopAdm%>&codCita='+codigo+'&fechaCita='+fecha+"&fg=trasladar");}

function cancelar(codigo,fecha,nombrePaciente)
{
	if(confirm('�Est� seguro que desea Cancelar esta Cita?'))
	{
		showPopWin('../common/run_process.jsp?fp=CITAS&actType=7&docType=CITAS&docId='+codigo+'&docNo='+codigo+'&fecha='+fecha+'&nombrePac="'+nombrePaciente+'"&compania=<%=session.getAttribute("_companyId")%>',winWidth*.75,winHeight*.35,null,null,'');
	}
}

function setIndex(x)
{
	parent.document.frmSearch.codCita.value=eval('document.form0.codCita'+x).value;
	parent.document.frmSearch.fechaRegistro.value=eval('document.form0.fechaCita'+x).value;
	parent.document.frmSearch.cds.value=eval('document.form0.cds'+x).value;
	parent.document.frmSearch.pacId.value=eval('document.form0.pacId'+x).value;
	parent.document.frmSearch.noAdmision.value=eval('document.form0.noAdmision'+x).value;
	parent.document.frmSearch.dob.value=eval('document.form0.dob'+x).value;
	parent.document.frmSearch.codPac.value=eval('document.form0.codPac'+x).value;
}

function setQIndex(hab,cds){parent.document.frmSearch.habitacion.value=hab;parent.document.frmSearch.cds.value=cds;}
function doAction(){if(document.form0.chkQ_x)if(document.form0.chkQ_x.value=='')setQIndex('','');}
function asociar(i, codigo, fecha, type){
   var btnId = $("#asociar"+i);
   var _type = (type)? "desligar" : "asociar"; 
   var estadoCita = (type)? "R" : "E";
   var pacId = "<%=pacId%>";
   var noAdmision = "<%=noAdmision%>";
   var fechaNacimiento = "<%=fechaNacimiento%>"; 
   var codMedico = "<%=codMedico%>";
   var nombreMedico = "<%=nombreMedico%>";
   var provincia = "<%=provincia%>";
   var sigla = "<%=sigla%>";
   var tomo = "<%=tomo%>";
   var asiento = "<%=asiento%>";
   var dCedula = "<%=dCedula%>";
   var pasaporte = "<%=pasaporte%>";
   var tipoPaciente = "<%=tipoPaciente%>";
   var codigoPaciente = "<%=codigoPaciente%>"; 
   var xtraMsg = " la cita #"+codigo+" con <%=sexo.equals("F")?"la":"el"%> paciente (<%=pacId%>-<%=noAdmision%>)";
   
   if (type){
      pacId = "null";
      noAdmision = "null";
      fechaNacimiento = ""; 
      codMedico = " ";
      nombreMedico = " ";
      provincia = "null";
      sigla = " ";
      tomo = "null";
      asiento = "null";
      dCedula = " ";
      pasaporte = " ";
      codigoPaciente = "null";
   }
   
   if (!btnId.hasClass("asociada")){
   
       parent.parent.CBMSG.confirm("Est�s seguro que quieres "+_type+xtraMsg+" ?", {
         cb: function(r){
           if (r=="Si") {
             btnId.addClass("asociada");
             
             if (validDateTime(i, type)){
           
                 if(executeDB('<%=request.getContextPath()%>',"update tbl_cdc_cita set pac_id = "+pacId+", admision = "+noAdmision+", fec_nacimiento=to_date('"+fechaNacimiento+"','dd/mm/yyyy'),nombre_paciente=(select nombre_paciente from vw_adm_paciente where pac_id="+pacId+"),cod_medico='"+codMedico+"', nombre_medico='"+nombreMedico+"', provincia="+provincia+", sigla='"+sigla+"', tomo="+tomo+",asiento="+asiento+",d_cedula='"+dCedula+"',pasaporte='"+pasaporte+"', tipo_paciente='"+tipoPaciente+"' ,cod_paciente = "+codigoPaciente+",usuario_modif='<%=(String) session.getAttribute("_userName")%>', fecha_modif=sysdate, estado_cita='"+estadoCita+"', xtra1='"+_type.toUpperCase()+"' where codigo = "+codigo+" and trunc(fecha_registro) = to_date('"+fecha+"','dd/mm/yyyy') ",null)) 
                   window.location.reload(true);
                 else 
                   parent.parent.CBMSG.error("No se ha podido "+_type+xtraMsg+" !");
               }
           }
         },
         btnTxt: "Si,No"
       });
       
   }
}

function validDateTime(i, type){
   
   if (type == "Y") return true;

   var cds = $("#cds"+i).val();
   var room = $("#habitacion"+i).val();
   var xDate = $("#fecha_cita"+i).val();
   var xTime = $("#hora_cita"+i).val();
   var hour= $("#hora_est"+i).val();
   var min= $("#min_est"+i).val();
   var codigo= $("#codCita"+i).val();
   var fechaRegistro= $("#fechaCita"+i).val();
   var filter='';
   
   <%if (!citasSopAdm.equals("Y") && !citasSopAdm.equals("S")){%> 
   if(getDBData('<%=request.getContextPath()%>','case when to_date(\''+xDate+'\',\'dd/mm/yyyy\')<trunc(sysdate) then 1 else 0 end','dual','','')==1){
     parent.parent.CBMSG.error('La fecha de la cita es menor al d�a de hoy!');return false;
   }
   <%}%>

   if(cds!=null&&cds!='')
     filter='centro_servicio='+cds;
   if(filter!='') filter+=' and ';
   
   filter+='habitacion=\''+room+'\' and estado_cita not in (\'C\',\'T\') and ((hora_cita<=to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\') and hora_final>to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')) or (hora_cita<to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')+(((coalesce('+hour+',hora_est,0) * 60) + coalesce('+min+',min_est,0)) / (24 * 60)) and hora_final>to_date(\''+xDate+' '+xTime+'\',\'dd/mm/yyyy hh12:mi am\')+(((coalesce('+hour+',hora_est,0) * 60) + coalesce('+min+',min_est,0)) / (24 * 60))))';
   
   filter+=' and codigo!='+codigo+' and trunc(fecha_registro)!=to_date(\''+fechaRegistro+'\',\'dd/mm/yyyy\')';
   
   if(hasDBData('<%=request.getContextPath()%>','tbl_cdc_cita',filter,'')){parent.parent.CBMSG.error('La Programaci�n de la Cita choca con otras Citas Programadas.\nPor favor revise la programaci�n!');return false;}return true;}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table align="center" width="<%=nCol * colWidth%>" cellpadding="0" cellspacing="0" border="0">
  <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
  <%=fb.formStart(true)%>
  <%=fb.hidden("citasSopAdm", citasSopAdm)%>
  <%=fb.hidden("pacId", pacId)%>
  <%=fb.hidden("noAdmision", noAdmision)%>
  <%=fb.hidden("nombreMedico", nombreMedico)%>
  <%=fb.hidden("codMedico", codMedico)%>
  <%=fb.hidden("codMedico", codMedico)%>
  <%=fb.hidden("provincia", provincia)%>
  <%=fb.hidden("sigla",sigla)%>
  <%=fb.hidden("tomo",tomo)%>
  <%=fb.hidden("asiento",asiento)%>
  <%=fb.hidden("dCedula",dCedula)%>
  <%=fb.hidden("pasaporte",pasaporte)%>
  <%=fb.hidden("tipoPaciente",tipoPaciente)%>
  <%=fb.hidden("fechaNacimiento",fechaNacimiento)%>
  <%=fb.hidden("codigoPaciente",codigoPaciente)%>
  <%=fb.hidden("sexo",sexo)%>
  <tr>
    <%
int sCol = 0;//column sequence
int c = 0;//counter per room
String col = "";//breaker
for (int i=1; i<=htQ.size(); i++)
{
	CommonDataObject cdoH = (CommonDataObject) htQ.get(""+i);
	String labelHab = cdoH.getColValue("descripcion"); 
	ArrayList alDet = (ArrayList) htGen.get(cdoH.getColValue("codigo"));
	if(alDet==null) alDet = new ArrayList();
	sCol = i;
%>
<td width="<%=colWidth%>" valign="top"><table align="center" width="100%" cellpadding="0" cellspacing="0" border="0" style="border-bottom:1.5pt solid #CCCCCC; border-right:1.5pt solid #CCCCCC;border-left:1.5pt solid #CCCCCC;">
    <tr>
      <td colspan="2"><table align="center" width="100%" cellpadding="1" cellspacing="0" border="0" style=" background-color:#E4E4E4; border-right:1.0pt solid #CCCCCC;border-left:1.0pt solid #CCCCCC;border-bottom:1.5pt solid #CCCCCC;border-top:1.0pt solid #CCCCCC;">
          <tr class="TextHeader">
            <td valign="middle" width="48%" align="center"><b><%=labelHab%></b></td>
            <td valign="middle" width="47%" align="center" height="30"><b><cellbytelabel>Programadas</cellbytelabel></b>&nbsp;[<%=alDet.size()%>]</td>
            <td valign="middle" width="5%">&nbsp;
              <%if(fg.equals("SO")){%>
              <%=fb.radio("chkQ_x",""+cdoH.getColValue("codigo"),false,false,false,"","","onClick=\"javascript:setQIndex(this.value,"+cdoH.getColValue("cds")+")\"")%>
              <%}%>
            </td>
          </tr>
        </table></td>
    </tr>
	<%
    for(int j = 0; j<alDet.size(); j++){
			CommonDataObject cdo = (CommonDataObject) alDet.get(j);
	%>
		<%=fb.hidden("codCita"+sCol+"_"+j,cdo.getColValue("codigo"))%> 
    <%=fb.hidden("fechaCita"+sCol+"_"+j,cdo.getColValue("fecha_registro"))%>
	<%=fb.hidden("cds"+sCol+"_"+j,cdo.getColValue("cds"))%>
	<%=fb.hidden("pacId"+sCol+"_"+j,cdo.getColValue("pac_id"))%>
	<%=fb.hidden("noAdmision"+sCol+"_"+j,cdo.getColValue("admision"))%>
	<%=fb.hidden("dob"+sCol+"_"+j,cdo.getColValue("dob"))%>
	<%=fb.hidden("codPac"+sCol+"_"+j,cdo.getColValue("codPac"))%>
	<%=fb.hidden("habitacion"+sCol+"_"+j,cdo.getColValue("habitacion"))%>
	<%=fb.hidden("fecha_cita"+sCol+"_"+j,cdo.getColValue("fecha_cita"))%>
	<%=fb.hidden("hora_cita"+sCol+"_"+j,cdo.getColValue("hora_cita"))%>
	<%=fb.hidden("hora_est"+sCol+"_"+j,cdo.getColValue("hora_est"))%>
	<%=fb.hidden("min_est"+sCol+"_"+j,cdo.getColValue("min_est"))%>
    
    <%
    String _hightlight = "";
    if (citasSopAdm.equalsIgnoreCase("S")||citasSopAdm.equalsIgnoreCase("Y")){
       if (pacId!=null && pacId.equals(cdo.getColValue("pac_id")) && (cdo.getColValue("admision","")).equals("") ) _hightlight = "style='background-color:yellow !important;'";
       else if (pacId!=null && pacId.equals(cdo.getColValue("pac_id")) && noAdmision.equals(cdo.getColValue("admision","")) )_hightlight = "style='background-color:red !important;'";
    } 
if (cdo.getColValue("estado_cita").trim().equals("X")){_hightlight = "style='background-color:red !important;'";}
    %>
	 
    <tr class="Text10Bold">
      <td class="" align="center" colspan="2" <%=_hightlight%>>&nbsp;<%=((cdo.getColValue("ocultarHora").trim().equals("N"))?cdo.getColValue("hora_inicio"):"")%>&nbsp;&nbsp; <%=(cdo.getColValue("ocultarHora").trim().equals("N")?"   -   "+cdo.getColValue("hora_final"):"")%>&nbsp;&nbsp;&nbsp;
        <%//if(fg.equals("inv")){%>
        <%=fb.radio("chkQ",sCol+"_"+j,false,false,false,"","","onClick=\"javascript:setIndex(this.value)\"")%>
        <%//}%>
      </td>
    </tr>
   <tr class="TextRow01">
      <td class="">&nbsp;<cellbytelabel>Paciente</cellbytelabel>:</td>
      <td class="Text10" style="border-bottom:1.0pt solid #F2F2F2;">&nbsp;<%=cdo.getColValue("nombre_paciente")%></td>
    </tr>
	<tr class="TextRow00">
      <td class="">&nbsp;<cellbytelabel>C&oacute;d. Ref.</cellbytelabel>:</td>
      <td class="Text10" style="border-bottom:1.0pt solid #F2F2F2;">&nbsp;<%=cdo.getColValue("cod_referencia")%></td>
    </tr>
    <tr class="TextRow01">
      <td class="" width="25%">&nbsp;<cellbytelabel>Doctor</cellbytelabel>:</td>
      <td class="Text10" width="75%" style="border-bottom:1.0pt solid #F2F2F2;">&nbsp;<%=cdo.getColValue("nombre_medico")%></td>
    </tr>
    <tr class="TextRow00">
      <td class="" width="25%">&nbsp;<cellbytelabel>Anest.</cellbytelabel>:</td>
      <td class="Text10" width="75%" style="border-bottom:1.0pt solid #F2F2F2;">&nbsp;<%=cdo.getColValue("nombre_anestesiologo")%></td>
    </tr>
	<tr class="TextRow01">
      <td class="">&nbsp;<cellbytelabel>Proced</cellbytelabel>.:</td>
      <td class="Text10" style="border-bottom:1.0pt solid #F2F2F2;">&nbsp;<%=cdo.getColValue("desc_procedimiento")%></td>
    </tr>
    <tr>
      <td class="" align="right" colspan="2"><%if(fg.equals("SO")){%>
      	<authtype type='53'>
        <a href="javascript:editar('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("fecha_registro")%>');" class="BottonTrasl" title="Editar"><cellbytelabel>Editar</cellbytelabel></a>
        </authtype>
        <authtype type='54'>&nbsp; 
        <a href="javascript:trasladar('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("fecha_registro")%>');" class="BottonTrasl" title="Trasladar"><cellbylabel>Trasladar</cellbylabel></a>
        </authtype>&nbsp;    
        <%if(citasSopAdm.equalsIgnoreCase("Y")||citasSopAdm.equalsIgnoreCase("S")){%>
        <%if(cdo.getColValue("estado_cita") != null && cdo.getColValue("estado_cita").equals("R")){%>
        <authtype type='56'><a href="javascript:asociar('<%=sCol+"_"+j%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("fecha_registro")%>');" class="BottonTrasl" title="Asociar" id="asociar<%=sCol+"_"+j%>"><cellbytelabel>+Adm</cellbytelabel></a></authtype>
        <%}else if (cdo.getColValue("xtra1") != null && cdo.getColValue("xtra1").equalsIgnoreCase("ASOCIAR") && cdo.getColValue("estado_cita").equals("E")){%>
          <authtype type='57'><a href="javascript:asociar('<%=sCol+"_"+j%>','<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("fecha_registro")%>', 'Y');" class="BottonTrasl" title="Desligar" id="asociar<%=sCol+"_"+j%>"><cellbytelabel>-Adm</cellbytelabel></a></authtype>
        <%}%>
        <%}%>
        
         <authtype type='55'>
        <a href="javascript:cancelar('<%=cdo.getColValue("codigo")%>','<%=cdo.getColValue("fecha_registro")%>','<%=cdo.getColValue("nombre_paciente")%>');" class="BottonTrasl" title="Cancelar"><cellbytelabel>Cancelar</cellbytelabel></a>
        </authtype>
        <%}%>
      </td>
    </tr>
    <tr height="2">
      <td style="background:#CCCCCC" colspan="2">&nbsp;</td>
    </tr>
  
  <%
    }
  %>


  </table></td>
<%
}//for i
%>
</tr>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}
%>
