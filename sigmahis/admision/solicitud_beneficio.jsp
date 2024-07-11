<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder" %>
<%@ page import="issi.admision.DatosSolicitud"%>
<%@ page import="issi.admision.DetalleSolicitud"%>
<%@ page import="issi.admin.IBIZEscapeChars"%> 

<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iDiagSol" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="iCobsol" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SBMgr" scope="page" class="issi.admision.SolicitudBeneficioMgr" />
<jsp:useBean id="vDiagSol" scope="session" class="java.util.Vector" />

<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SBMgr.setConnection(ConMgr);

SQL2BeanBuilder sbb = new SQL2BeanBuilder();
CommonDataObject cdo = new CommonDataObject();
CommonDataObject cdo1 = new CommonDataObject();
DatosSolicitud dat = new DatosSolicitud();

ArrayList al = new ArrayList(); 
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String pac_id = request.getParameter("pac_id");
String cod_pac = request.getParameter("cod_pac");
String admision = request.getParameter("admision");
String secuencia = request.getParameter("secuencia");
String fecha_nacimiento = request.getParameter("fecha_nacimiento");
String change = request.getParameter("change");
String empresa = request.getParameter("empresa");
String fp = request.getParameter("fp");
int rn =0;
String stado="";
boolean viewMode = false;

int coLastLineNo = 0;
int diagLastLineNo = 0;
String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");

if (mode == null) mode = "add";
if (tab == null) tab = "0";
if (admision == null) admision = "";
if (mode.equalsIgnoreCase("view")) viewMode = true;

//if (secuencia == null) secuencia = "0";
if (request.getParameter("diagLastLineNo") != null) diagLastLineNo = Integer.parseInt(request.getParameter("diagLastLineNo"));
if (request.getParameter("coLastLineNo") != null) coLastLineNo = Integer.parseInt(request.getParameter("coLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
if(fp== null)
{
if(secuencia == null || secuencia.trim().equals("") )
{
sql="select count(*)as cantidad from tbl_adm_solicitud_beneficio a ,tbl_adm_beneficios_x_admision b where a.pac_id = "+pac_id+" and a.admision="+admision+" and a.empresa=b.empresa and a.pac_id=b.pac_id and b.prioridad=1 and a.estatus='A'";
rn  = CmnMgr.getCount(sql);
	
System.out.println("mode == "+mode+"  rn = "+rn);

if(rn > 0)
{
  sql="select secuencia,empresa, paciente,to_char(fecha_nacimiento,'dd/mm/yyyy')as fecha_nacimiento from tbl_adm_solicitud_beneficio where pac_id = "+pac_id+" and admision="+admision+" and estatus='A'";
  cdo = SQLMgr.getData(sql);
  secuencia = cdo.getColValue("secuencia");
  empresa = cdo.getColValue("empresa");
  cod_pac = cdo.getColValue("paciente");
  fecha_nacimiento = cdo.getColValue("fecha_nacimiento");
  if(!viewMode)mode="edit";
  System.out.println("mode == "+mode+"  rn = "+rn+" secuencia   "+secuencia+"empresa =="+empresa);

  //viewMode = true;
}//if cantidad
else
{
  sql="select a.paciente as paciente,to_char(a.fecha_nacimiento,'dd/mm/yyyy')as fechaNacimiento, pac.provincia||'-'||pac.sigla||'-'||pac.tomo||'-'||pac.asiento||' -'||pac.d_cedula as cedula,pac.pasaporte,  pac.primer_nombre||' '||pac.segundo_nombre||' '||decode(pac.apellido_de_casada,null,pac.primer_apellido||' '||pac.segundo_apellido,pac.apellido_de_casada)as pacienteNombre, a.empresa as empresa, a.poliza as poliza, a.certificado as certificado, a.tipo_poliza as tipoPoliza ,a.categoria_admi, adm.categoria as categoria,cat.descripcion as admisionDesc,b.nombre as empresaDesc, adm.dias_hospitalizados as dias_hosp,adm.pac_id as pacId,to_char(pac.f_nac,'dd/mm/yyyy') as fechaModifica from tbl_adm_beneficios_x_admision a,(select categoria,dias_hospitalizados , estado,pac_id,secuencia from tbl_adm_admision) adm,vw_adm_paciente pac ,(select descripcion ,codigo from tbl_adm_categoria_admision) cat,(select codigo,nombre from tbl_adm_empresa) b where a.prioridad = 1 and adm.estado='A' and pac.pac_id=adm.pac_id and adm.categoria=cat.codigo and a.empresa=b.codigo and a.pac_id="+pac_id+" and a.admision= "+admision+" and adm.pac_id=a.pac_id and a.admision = adm.secuencia";
dat = (DatosSolicitud) sbb.getSingleRowBean(ConMgr.getConnection(), sql, DatosSolicitud.class);
if(dat==null)
dat= new DatosSolicitud();
  
  dat.setAdmision(admision);
  dat.setSecuencia("0");
  dat.setFecha(cDateTime.substring(0,10));
  dat.setFechaAdiciona(cDateTime);
  dat.setUsuarioAdiciona((String) session.getAttribute("_userName"));
  if(!viewMode)mode="add";
 
  viewMode = true;
   change="1";
}
}//fp=null
if(secuencia != null && !secuencia.trim().equals(""))
{
sql="select pac.primer_nombre||' '||pac.segundo_nombre||' '||decode(pac.apellido_de_casada,null,pac.primer_apellido||' '||pac.segundo_apellido,pac.apellido_de_casada)as pacienteNombre,pac.provincia||'-'||pac.sigla||'-'||pac.tomo||'-'||pac.asiento||' -'||pac.d_cedula as cedula,pac.pasaporte as pasaporte, to_char(b.fecha_nacimiento,'dd/mm/yyyy') as fechaNacimiento,  b.paciente as paciente, b.admision as admision,b.empresa as empresa , b.secuencia as secuenca, to_char(b.fecha,'dd/mm/yyyy')as fecha,b.poliza as poliza, b.certificado as certificado, b.propietario_de_poliza as propietarioDePoliza, b.pagada_hasta as pagadaHasta, b.tipo_poliza as tipoPoliza, b.observaciones as observaciones, b.co_pago as coPago, nvl(b.dia_evento,'E') as diaEvento, b.estatus as estatus, b.usuario_adiciona as usuarioAdiciona, to_char(b.fecha_adiciona,'dd/mm/yyyy hh12:mi:ss am')as fechaAdiciona, b.dias_hosp as diasHosp, b.tipo_valor as tipoValor,b.dias_copago as diasCopago, b.pase as pase , b.pase_k as paseK,a.nombre as empresaDesc,admi.categoria as categoria , cat.descripcion as admisionDesc, b.pac_id as pacId,b.secuencia as secuencia,b.empresa as empresa,to_char(pac.f_nac,'dd/mm/yyyy') as fechaModifica from tbl_adm_solicitud_beneficio b,vw_adm_paciente pac,tbl_adm_empresa a ,tbl_adm_categoria_admision cat,tbl_adm_admision admi, tbl_adm_beneficios_x_admision benef where b.pac_id= "+pac_id+" and b.admision= "+admision+" and b.secuencia="+secuencia+" and pac.pac_id= b.pac_id and a.codigo=b.empresa and admi.categoria = cat.codigo and admi.pac_id=b.pac_id and b.estatus='A' and b.empresa = "+empresa+" and /*agregado join*/ (b.pac_id = benef.pac_id and benef.prioridad = 1 and nvl(benef.estado,'A') = 'A') and (admi.pac_id = benef.pac_id and admi.secuencia = benef.admision and a.codigo = benef.empresa) ";
dat = (DatosSolicitud) sbb.getSingleRowBean(ConMgr.getConnection(), sql, DatosSolicitud.class);
  if(dat==null){
  dat= new DatosSolicitud();
  dat.setSecuencia("0");
  dat.setFecha(cDateTime.substring(0,10));
  dat.setFechaAdiciona(cDateTime);
  dat.setUsuarioAdiciona((String) session.getAttribute("_userName"));
  }
if(change == null)
{
      iDiagSol.clear();
      iCobsol.clear();
      vDiagSol.clear();
sql="select a.codigo_paciente as codigoPaciente, a.admision as admision, a.empresa as empresa, a.solicitud as solicitud, a.secuencia as secuencia, a.tipo_detalle as tipoDetalle, coalesce(''|| a.diagnostico,a.procedimiento) as codigo, a.usuario_creacion as usuarioCreacion ,to_char(a.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')as fechaCreacion, a.pase_k as paseK, coalesce(decode(d.observacion, null,d.nombre,d.observacion),decode(p.observacion,null,p.descripcion,p.observacion)) as descripcion from tbl_adm_detalle_solicitud a,tbl_cds_procedimiento p,tbl_cds_diagnostico d where a.pac_id ="+pac_id+" and a.admision = "+admision+" and solicitud="+secuencia+" and a.procedimiento = p.codigo(+) and  a.diagnostico= d.codigo (+) and a.empresa="+empresa;
    al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleSolicitud.class); 
    diagLastLineNo = al.size();
    for (int i=0; i<al.size(); i++)
    {
      DetalleSolicitud ds = (DetalleSolicitud) al.get(i);

      if (i < 10) key = "00" + i;
      else if (i < 100) key = "0" + i;
      else key = "" + i;
      ds.setKey(key);

      try
      {
        iDiagSol.put(key, ds);
        vDiagSol.add(ds.getCodigo());
      }
      catch(Exception e)
      {
        System.err.println(e.getMessage());
      }
    }//for
    
sql="select co.codigo_paciente as codigoPaciente ,co.admision as admision, co.empresa as empresa, co.solicitud as solicitud, co.secuencia as secuencia,co.clasifica_cober as clasificaCober, co.descripcion as descripcion, co.monto as monto,co.tipo_valor as tipoValor, co.tipo_habitacion as tipoHabitacion, co.compania as compania, co.deducible as deducible, co.deduc_antes_pago as deducAntesPago, co.mto_excedente as mtoExcedente,co.tipo_val_excedente as tipoValExcedente, co.usuario_creacion as usuarioCreacion, to_char(co.fecha_creacion,'dd/mm/yyyy hh12:mi:ss am')as fechaCreacion, co.deducible_acumulado as deducibleAcumulado, co.monto_acumulado as montoAcumulado, co.mto_pac_excedente as mtoPacExcedente, co.tipo_val_pac as tipoValPac, co.limite_acum_hon as limiteAcumHon, co.limite_acum_misc as limiteAcumMisc, co.monto_emp_det_lim as montoEmpDetLim, co.monto_pac_det_lim as montoPacDetLim, co.tipo_val_medl as tipoValmedl, co.tipo_val_mpdl as tipoValMpdl, co.pase as pase,co.precio_habitacion as precioHabitacion, nvl(co.gasto_no_cubierto,'N') as gastoNoCubierto ,co.pase_k as paseK, co.monto_cli_det_lim as montoCliDetLim, co.tipo_val_mcdl as tipoValMcdl from tbl_adm_cobertura_solicitud co where co.pac_id= "+pac_id+"and co.admision="+admision+" and co.solicitud="+secuencia+" and co.empresa ="+empresa;
    al = sbb.getBeanList(ConMgr.getConnection(),sql,DetalleSolicitud.class); 
    coLastLineNo = al.size();
    for (int i=0; i<al.size(); i++)
    {
      DetalleSolicitud ds = (DetalleSolicitud) al.get(i);
      if (i < 10) key = "00" + i;
      else if (i < 100) key = "0" + i;
      else key = "" + i;
      ds.setKey(key);
      try
      {
        iCobsol.put(key, ds);
      }
      catch(Exception e)
      {
        System.err.println(e.getMessage());
      }
    }//for
      
}//change

sql="SELECT DISTINCT ST.CODIGO,ST.DESCRIPCION||' - '||ST.PRECIO||' - '||st.codigo FROM TBL_SAL_TIPO_HABITACION ST, TBL_SAL_HABITACION SH, TBL_FAC_DETALLE_TRANSACCION FD,TBL_SAL_CAMA SC WHERE SH.COMPANIA = SC.COMPANIA AND SH.CODIGO = SC.HABITACION AND ST.COMPANIA = SC.COMPANIA AND ST.CODIGO = SC.TIPO_HAB AND SH.COMPANIA = 1 AND    ST.PRECIO = FD.MONTO AND SC.HABITACION = FD.HABITACION AND FD.pac_id ="+pac_id+" AND FD.FAC_SECUENCIA = "+admision+" ORDER BY 2";
}//
}
else 
{dat.setSecuencia("0");
if(dat==null)
  dat= new DatosSolicitud();
  dat.setSecuencia("0");
  dat.setFecha(cDateTime.substring(0,10));
  dat.setFechaAdiciona(cDateTime);
  dat.setUsuarioAdiciona((String) session.getAttribute("_userName"));
  sql="";
  if(!viewMode){mode="add";
  viewMode = false;}
}

%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Solicitud de beneficio- '+document.title;
function removeCob(k)
{
  var retVal='<%=IBIZEscapeChars.forURL("count(*)")%>';
  var sec=eval('document.form2.secuencia'+k).value;
  var msg='';
  if(hasDBData('<%=request.getContextPath()%>','tbl_adm_cobertura_sol1','empresa=<%=empresa%> and admision=<%=admision%> and pac_id=<%=pac_id%> and solicitud=<%=secuencia%> and secuencia_cob=\''+sec+'\'',''))msg+='\n- Cobertura solicitud 1';
if(msg=='')
  {
    if(confirm('¿Está seguro de eliminar la Cobertura?'))
    {
      removeItem('form2',k);
      form2BlockButtons(true);
      document.forms[2].submit();
    }
  }
  else CBMSG.warning('La Cobertura no se puede eliminar ya que tiene relacionada los siguientes documentos:'+msg);
}
function doAction()
{}
function showDetalleCobertura(k)
{
var sec = eval('document.form2.secuencia'+k).value;
abrir_ventana1('../admision/detalle_cobertura_convenio.jsp?&pac_id=<%=pac_id%>&cod_pac=<%=cod_pac%>&fecha_nacimiento=<%=fecha_nacimiento%>&solicitud=<%=secuencia%>&admision=<%=admision%>&empresa=<%=empresa%>&secuencia_cob='+sec);
}
function showPaciente()
{
abrir_ventana1('../admision/sel_paciente_list.jsp?fp=sol_beneficio');
}

function showDiagnostico(k)
{
var tipo = eval('document.form1.tipo_detalle'+k).value;

if(tipo=='P')
abrir_ventana1('../expediente/listado_procedimiento.jsp?fp=convenio_beneficio&index='+k);
else
{
  var diag = eval('document.form1.tipo_diag'+k).value;
  abrir_ventana1('../admision/diagnostico_sol_list.jsp?fp=convenio_beneficio&index='+k+'&filter='+diag+'&pacId=<%=pac_id%>&noAdmision=<%=admision%>');
}
}
function showDetalleLimite(k)
{
if(eval('document.form2.empresa').value=="2")
{
if(document.getElementById("det"+k).style.visibility=="hidden")
{
document.getElementById("det"+k).style.visibility = "visible"; 
document.getElementById("det"+k).style.height = "auto";
document.getElementById("det"+k).style.display = "";
}
 else 
 {
  document.getElementById("det"+k).style.visibility = "hidden"; 
  document.getElementById("det"+k).style.height = "1";
  document.getElementById("det"+k).style.display = "none";
  }
}else CBMSG.warning('Detalle solo para ASSA compañia de seguros s.a');
}
function setDias(val)
{
	
	if(val == 'D')
	{	
		//CBMSG.warning(val);
		eval('document.form0.diasCopago').readOnly=false;
		eval('document.form0.diasCopago').className='FormDataObjectEnabled';
		
	}else 
	{
		eval('document.form0.diasCopago').readOnly=true;
		eval('document.form0.diasCopago').className='FormDataObjectDisabled';
		eval('document.form0.diasCopago').value='';
	}
}
function setDiag(obj,i)
{
var val = obj.value;
if(val=="D")
  eval('document.form1.tipo_diag'+i).disabled=false;
else
  eval('document.form1.tipo_diag'+i).disabled=true;
}
function setHabita(obj,i)
{
var val = obj.value;
if(val=="1")
{
  eval('document.form2.tipo_habitacion'+i).className = 'FormDataObjectEnabled';
  eval('document.form2.tipo_habitacion'+i).disabled=false;
}
else
{ 
  eval('document.form2.tipo_habitacion'+i).className = 'FormDataObjectDisabled';
  eval('document.form2.tipo_habitacion'+i).disabled=true;
}
if(val=="2" && eval('document.form2.secuencia'+i).value !="0")
{
  eval('document.form2.addDetalle'+i).className = 'FormDataObjectDisabled';
  eval('document.form2.addDetalle'+i).disabled = false;
}
else  eval('document.form2.addDetalle'+i).disabled = true;
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
  <jsp:param name="title" value="SOLICITUD DE BENEFICIOS"></jsp:param>
</jsp:include>
<table align="center" width="100%" cellpadding="0" cellspacing="0">   
  <tr>  
    <td>   
<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">
<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
<table align="center" width="100%" cellpadding="1" cellspacing="1">

      <%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
      <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
      <%=fb.formStart(true)%> 
      <%=fb.hidden("mode",mode)%> 
      <%=fb.hidden("baction","")%>
      <%=fb.hidden("pase",dat.getPase())%>
      <%=fb.hidden("pase_k",dat.getPaseK())%>
      <%=fb.hidden("pagada_hasta",dat.getPagadaHasta())%> 
      <%=fb.hidden("tipo_poliza",dat.getTipoPoliza())%>
      <%=fb.hidden("usuario_adiciona",dat.getUsuarioAdiciona())%>
      <%=fb.hidden("fecha_adiciona",dat.getFechaAdiciona())%>
      <%=fb.hidden("pac_id",dat.getPacId())%>
      <%=fb.hidden("diagSize",""+iDiagSol.size())%>
      <%=fb.hidden("coSize",""+iCobsol.size())%>
      <%=fb.hidden("coLastLineNo",""+coLastLineNo)%>
      <%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
        <tr class="TextHeader">
              <td colspan="4"><cellbytelabel id="1">DATOS DEL PACIENTE</cellbytelabel></td>
        </tr>
        <tr class="TextRow01"> 
          <td><cellbytelabel id="2">Admisi&oacute;n</cellbytelabel></td>
          <td colspan="3">
  		  <%=fb.hidden("fecha_nacimiento",dat.getFechaNacimiento())%>
          <%=fb.textBox("f_nac",dat.getFechaModifica(),true,false,true,15)%>
          <%=fb.textBox("cod_pac",dat.getPaciente(),true,false,true,5)%>
          <%=fb.textBox("admision",dat.getAdmision(),true,false,true,5)%>
          <%=fb.textBox("nombre",dat.getPacienteNombre(),false,false,true,30)%>
          <%=fb.button("addPaciente","...",true,viewMode,null,"onClick=\"javascript:showPaciente()\"","Agregar Paciente")%></td>
        </tr>
        <tr class="TextRow01">  
          <td width="20%"><cellbytelabel id="3">C&eacute;dula/pasaporte</cellbytelabel></td>
          <td width="30%"><%=fb.textBox("cedula",dat.getCedula(),false,false,true,15)%>
          <%=fb.textBox("pasaporte",dat.getPasaporte(),false,false,true,15)%></td>
          <td width="25%"><cellbytelabel id="4">D&iacute;as aprobados de hospitalizaci&oacute;n</cellbytelabel></td>
          <td width="25%"><%=fb.intBox("diasHosp",dat.getDiasHosp(),false,false,viewMode,15,2)%></td>
        </tr>
        <tr class="TextRow01"> 
          <td><cellbytelabel id="5">Categor&iacute;a</cellbytelabel></td>
          <td colspan="3"><%=fb.textBox("categoria",dat.getAdmisionDesc(),false,false,true,15)%></td>
        </tr>
                <tr class="TextHeader">
          <td colspan="4"><cellbytelabel id="6">SOLICITUD</cellbytelabel></td>
        </tr> 

        <tr class="TextRow01">      
            <td><cellbytelabel id="7">No. Solicitud</cellbytelabel></td>
            <td><%=fb.intBox("solicitudNo",((dat.getSecuencia()!= null)?dat.getSecuencia():"0"),false,false,true,15)%></td><!---secuencia-->
            <td><cellbytelabel id="8">Fecha</cellbytelabel><jsp:include page="../common/calendar.jsp" flush="true">
                      <jsp:param name="noOfDateTBox" value="1" />
                      <jsp:param name="clearOption" value="true" />
                      <jsp:param name="nameOfTBox1" value="fecha" />
                      <jsp:param name="valueOfTBox1" value="<%=dat.getFecha()%>" />
											<jsp:param name="readonly" value="<%=(viewMode||mode.trim().equals("edit"))?"y":"n"%>"/>
                      </jsp:include></td>
            <td><cellbytelabel id="9">Estatus</cellbytelabel><%=fb.select("estatus","A = ACTIVO, I = INACTIVO",dat.getEstatus())%></td>
        </tr>
        <tr class="TextRow01"> 
            <td><cellbytelabel id="10">Observaciones</cellbytelabel></td>
            <td colspan="3"><%=fb.textarea("observaciones",dat.getObservaciones(),false,false,viewMode,60,3,2000,"","width:100%","")%></td>
         </tr>
  
        <tr class="TextHeader">
          <td colspan="4"><cellbytelabel id="11">DATOS DE LA ASEGURADORA</cellbytelabel></td>
        </tr> 
        <tr class="TextRow01">      
          <td><cellbytelabel id="12">Aseguradora</cellbytelabel></td>
          <td><%=fb.textBox("empresa",dat.getEmpresa(),true,false,viewMode,5)%>
          <%=fb.textBox("nombreEmpresa",dat.getEmpresaDesc(),false,false,true,30)%>
          </td>
          <td><cellbytelabel id="13">Poliza</cellbytelabel></td><td><%=fb.textBox("poliza",dat.getPoliza(),false,false,true,20)%></td>
        </tr>
        <tr class="TextRow01">  
          <td><cellbytelabel id="14">Due&ntilde;o</cellbytelabel></td>
          <td><%=fb.textBox("dueño",dat.getPropietarioDePoliza(),false,false,viewMode,36)%></td>
          <td><cellbytelabel id="15">Certificado</cellbytelabel></td>
          <td><%=fb.textBox("certificado",dat.getCertificado(),false,false,true,20)%></td>
       </tr>
       <tr class="TextHeader">
          <td colspan="4"><cellbytelabel id="16">COPAGO</cellbytelabel></td>
       </tr>
      <tr class="TextRow01">      
        <td><cellbytelabel id="16">Copago</cellbytelabel></td>
        <td><%=fb.decBox("coPago",dat.getCoPago(),false,false,false,5,12.2)%>
        <%=fb.select("tipoValor","P=%, M=$",dat.getTipoValor())%></td>
        <td colspan="2"> X <%=fb.select("diaEvento","E = EVENTO, D = DIARIO",dat.getDiaEvento(),false,false,0,"","","onChange=\"javascript:setDias(this.value)\"")%><cellbytelabel id="17">D&iacute;as</cellbytelabel>
			
        <%=fb.intBox("diasCopago",dat.getDiasCopago(),false,false,(!dat.getDiaEvento().trim().equals("D")||viewMode),3,3)%> </td>
      </tr>
  <%fb.appendJsValidation("if(error>0)doAction();");%>    
  <tr class="TextRow02">
          <td colspan="4" align="right">
            <cellbytelabel id="18">Opciones de Guardar</cellbytelabel>: 
            <!--<%=fb.radio("saveOption","N")%>Crear Otro --->
            <%=fb.radio("saveOption","O",true,(viewMode && mode.trim().equals("view")),false)%><cellbytelabel id="19">Mantener Abierto</cellbytelabel> 
            <%=fb.radio("saveOption","C",false,(viewMode && mode.trim().equals("view")),false)%><cellbytelabel id="20">Cerrar</cellbytelabel> 
            <%=fb.submit("save","Guardar",true,(viewMode && mode.trim().equals("view")),null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

</table>  
  <!-- TAB0 DIV END HERE-->
</div>
<!-- TAB1 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

        <table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
         <%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
         <%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
         <%=fb.formStart(true)%>
         <%=fb.hidden("tab","1")%>
         <%=fb.hidden("mode",mode)%>
         <%=fb.hidden("baction","")%>
         <%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
         <%=fb.hidden("solicitud",secuencia)%>
         <%=fb.hidden("admision",admision)%>
         <%=fb.hidden("pac_id",pac_id)%>
         <%=fb.hidden("cod_pac",cod_pac)%>
         <%=fb.hidden("empresa",empresa)%>
         <%=fb.hidden("diagSize",""+iDiagSol.size())%>
         <%=fb.hidden("coSize",""+iCobsol.size())%>
         <%=fb.hidden("coLastLineNo",""+coLastLineNo)%>
         <%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
            <tr class="TextHeader">
              <td colspan="6"><cellbytelabel id="21">DIAGN&Oacute;STICOS Y PROCEDIMIENTOS</cellbytelabel></td>
              <td align="center"><%=fb.submit("btnagrega","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Diagnostico--Procedimiento")%></td>
            </tr>
            <tr class="TextHeader" align="center">
              <td width="10%"><cellbytelabel id="22">No.</cellbytelabel></td>
              <td width="14%"><cellbytelabel id="23">Tipo de detalle</cellbytelabel></td>
              <td width="25%"><cellbytelabel id="24">Diagn&oacute;stico</cellbytelabel></td>
              <td width="10%"><cellbytelabel id="25">C&oacute;digo</cellbytelabel></td>
              <td width="26%" colspan="2"><cellbytelabel id="26">Descripci&oacute;n</cellbytelabel></td>
              <td width="5%">&nbsp;</td>
            </tr>
<%    
al = CmnMgr.reverseRecords(iDiagSol); 
for (int i=0; i<iDiagSol.size(); i++)
{
   key = al.get(i).toString();    
   DetalleSolicitud det = (DetalleSolicitud) iDiagSol.get(key);
   String color = "TextRow02";
   if (i % 2 == 0) color = "TextRow01";
%>
      <%=fb.hidden("key"+i,det.getKey())%> 
      <%=fb.hidden("remove"+i,"")%>
       <%=fb.hidden("pase_k"+i,det.getPaseK())%>
      <%=fb.hidden("usuario_creacion"+i,det.getUsuarioCreacion())%>
      <%=fb.hidden("fecha_creacion"+i,det.getFechaCreacion())%>             
            
            <tr class="<%=color%>" align="center">  
              <td><%=fb.intBox("secuencia"+i,det.getSecuencia(),false,false,true,5,5)%></td>
              <td><%=fb.select("tipo_detalle"+i,"****,D = DIAGNOSTICO, P = PROCEDIMIENTO",det.getTipoDetalle(),false,viewMode,0,"",null,"onChange=\"javascript:setDiag(this,'"+i+"')\"")%></td>
              <td><%=fb.select("tipo_diag"+i,"S= DIAGNOSTICOS SOLICITADOS ,L = LISTADO DE DIAGNOSTICOS","",false,(det.getTipoDetalle().trim().equals("P") ||viewMode),0,"",null,null)%>
              </td>
              <td><%=fb.textBox("codigo"+i,det.getCodigo(),false,false,true,5)%></td>
              <td colspan="2"><%=fb.textBox("descDiagnostico"+i,det.getDescripcion(),false,false,true,30)%>
              <%=fb.button("addDiagnostico"+i,"...",true,viewMode,null,null,"onClick=\"javascript:showDiagnostico('"+i+"')\"","Agregar Diagnostico o Procedimiento")%></td>

              <td align="center"><%=fb.submit("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td> 
            </tr>
        
    <%}
    fb.appendJsValidation("if(error>0)doAction();");
     %>   
        <tr class="TextRow02">
          <td colspan="7" align="right">
            <cellbytelabel id="18">Opciones de Guardar</cellbytelabel>: 
            <!--<%=fb.radio("saveOption","N")%>Crear Otro --->
            <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="19">Mantener Abierto </cellbytelabel>
            <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="20">Cerrar</cellbytelabel> 
            <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
<%=fb.formEnd(true)%>
<!-- ================================   F O R M   E N D   H E R E   ================================ -->
        </table>
<!-- TAB1 DIV END HERE-->
</div>
<!-- TAB2 DIV START HERE-->
<div class="dhtmlgoodies_aTab">
        <table align="center" width="100%" cellpadding="1" cellspacing="1">
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("fecha_nacimiento",fecha_nacimiento)%>
<%=fb.hidden("solicitud",secuencia)%>
<%=fb.hidden("admision",admision)%>
<%=fb.hidden("empresa",empresa)%>
<%=fb.hidden("pac_id",pac_id)%>
<%=fb.hidden("cod_pac",cod_pac)%>
<%=fb.hidden("diagSize",""+iDiagSol.size())%>
<%=fb.hidden("coSize",""+iCobsol.size())%>
<%=fb.hidden("coLastLineNo",""+coLastLineNo)%>
<%=fb.hidden("diagLastLineNo",""+diagLastLineNo)%>
<%=fb.hidden("baction","")%>
            <tr class="TextHeader">
                <td colspan="13">COBERTURA DE LA EMPRESA/ASEGURADORA</td>
                <td align="center"></td>
            </tr>
            <tr class="TextRow02"><td colspan="14">&nbsp;</td>  </tr>
            <tr class="TextRow01"><td colspan="14"></td> </tr>
            <tr class="TextHeader" align="center">
              <td width="20%"><cellbytelabel id="27">Clasificaci&oacute;n de Servicios</cellbytelabel></td>
              <td width="8%"><cellbytelabel id="28">L&iacute;mite M&aacute;ximo</cellbytelabel></td>
              <td width="5%">%-$</td>
              <td width="3%">&nbsp;</td>
              <td width="9%"><cellbytelabel id="29">Deducible</cellbytelabel></td>
              <td width="5%"><cellbytelabel id="30">Empresa</cellbytelabel></td>
              <td width="5%">%-$</td>
              <td width="5%"><cellbytelabel id="31">Paciente</cellbytelabel></td>
              <td width="5%">%-$</td>
              <td width="5%"><cellbytelabel id="32">Dif</cellbytelabel></td>
              <td width="20%" colspan="2" ><cellbytelabel id="33">Tipo Habitaci&oacute;n/Precio</cellbytelabel></td>
              <td width="5%" align="right"><%=fb.submit("covertura","+",false,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar Cobertura")%></td>
              <td width="5%"></td>
            </tr>

<% 
al.clear();
int validCob = iCobsol.size();
al = CmnMgr.reverseRecords(iCobsol);  
for (int i=0; i<iCobsol.size(); i++)
{
   key = al.get(i).toString();    
   DetalleSolicitud des = (DetalleSolicitud) iCobsol.get(key);
   String color = "TextRow02";
   if (i % 2 == 0) color = "TextRow01";
    String displayCob = "";
   if (des.getStatus() != null && des.getStatus().equalsIgnoreCase("D"))
    {
      displayCob = " style=\"display:none\"";
    }
%>
      <%=fb.hidden("key"+i,des.getKey())%> 
      <%=fb.hidden("remove"+i,"")%>
      <%=fb.hidden("pase"+i,des.getPase())%>
      <%=fb.hidden("pase_k"+i,des.getPaseK())%>
      <%=fb.hidden("usuario_creacion"+i,des.getUsuarioCreacion())%>
      <%=fb.hidden("fecha_creacion"+i,des.getFechaCreacion())%>             
      <%=fb.hidden("secuencia"+i,des.getSecuencia())%>
      <%=fb.hidden("status"+i,des.getStatus())%>
      <%=fb.hidden("deduc_antes_pago"+i,des.getDeducAntesPago())%>
      <%=fb.hidden("deducible_acumulado"+i,des.getDeducibleAcumulado())%>
      <%=fb.hidden("monto_acumulado"+i,des.getMontoAcumulado())%>
      <%=fb.hidden("limite_acum_hon"+i,des.getLimiteAcumHon())%>
      <%=fb.hidden("limite_acum_misc"+i,des.getLimiteAcumMisc())%>
            <tr class="<%=color%>" align="center"<%=displayCob%>>
              <td>
              <%=fb.select(ConMgr.getConnection(),"SELECT DISTINCT CODIGO,DESCRIPCION||' - '||codigo FROM   TBL_CDS_CLASIF_SERVICIO ORDER BY 1","clasifica_cober"+i,des.getClasificaCober(),false,viewMode,0,"",null,"onChange=\"javascript:setHabita(this,'"+i+"')\"")%>
              </td>
              <td><%=fb.decBox("monto"+i,des.getMonto(),false,false,viewMode,5,12.2)%></td>
              <td><%=fb.select("tipo_valor"+i,"M=$,P=%",des.getTipoValor(),false,viewMode,0,"",null,null)%></td>
              <td>
              <%=fb.button("addDetLimite"+i,"...",true,viewMode,null,null,"onClick=\"javascript:showDetalleLimite('"+i+"')\"","Detalle Limite")%>            
              </td>
              <td><%=fb.decBox("deducible"+i,des.getDeducible(),false,false,viewMode,5,12.2)%></td>
              <td><%=fb.decBox("mto_excedente"+i,des.getMtoExcedente(),false,false,viewMode,5,12.2)%></td>
              <td><%=fb.select("tipo_val_excedente"+i,"M=$,P=%",des.getTipoValExcedente(),false,viewMode,0,"",null,null)%></td>
              <td ><%=fb.decBox("mto_pac_excedente"+i,des.getMtoPacExcedente(),false,false,viewMode,5,12.2)%></td>
              <td><%=fb.select("tipo_val_pac"+i,"M=$,P=%",des.getTipoValPac(),false,viewMode,0,"",null,null)%></td>
              <td><%=fb.checkbox("gasto_no_cubierto"+i,"S",(des.getGastoNoCubierto().trim().equals("S")),viewMode,null,null,"")%></td>
<td colspan="2"><%=fb.select(ConMgr.getConnection(),sql,"tipo_habitacion"+i,des.getTipoHabitacion(),false,(!(des.getClasificaCober().trim().equals("1")) || viewMode),0,"",null,"")%></td>

              <%//=fb.textBox("tipo_habitacion"+i,cdo.getColValue("tipo_habitacion"),false,false,true,15)%>
              <%//=fb.decBox("precio_habitacion"+i,cdo.getColValue("precio_habitacion"),false,false,true,5,5.2)%>
              <%//=fb.button("addHabitacion"+i,"...",true,false,null,null,"onClick=\"javascript:showHabitacion()\"","Habitación")%>  
              <td align="right"><%=fb.button("addDetalle"+i,"Def..",true,(!(des.getClasificaCober().trim().equals("2")&& !des.getSecuencia().equals("0")) ||viewMode),null,null,"onClick=\"javascript:showDetalleCobertura('"+i+"')\"","Definir Coberturas")%></td>
              <td rowspan="2"><%=fb.button("rem"+i,"X",true,viewMode,null,null,"onClick=\"javascript:removeCob("+i+")\"","Eliminar")%></td>    
            </tr>
            
            <tr class="TextRow01">  
            <td colspan="13" align="center"> 
            <div id="det<%=i%>" name="det<%=i%>" style="visibility:hidden;display:none;"> 
            <table align="center">
            <tr class="TextHeader" align="center">
              
              <td colspan="4"><cellbytelabel id="34">Descuento</cellbytelabel></td>
              <td colspan="4"><cellbytelabel id="30">Empresa</cellbytelabel></td>
              <td colspan="4"><cellbytelabel id="31">Paciente</cellbytelabel></td>
              
            </tr>
            <tr class="TextRow02" align="center">   
              
              <td colspan="4"><%=fb.decBox("monto_cli_det_lim"+i,des.getMontoCliDetLim(),false,false,viewMode,5,5.2)%>
              <%=fb.select("tipo_val_mcdl"+i,"M=$,P=%",des.getTipoValMcdl())%></td>
              <td colspan="4"><%=fb.decBox("monto_emp_det_lim"+i,des.getMontoEmpDetLim(),false,false,viewMode,5,5.2)%>
              <%=fb.select("tipo_val_medl"+i,"M=$,P=%",des.getTipoValMedl())%></td>
              <td colspan="4"><%=fb.decBox("monto_pac_det_lim"+i,des.getMontoPacDetLim(),false,false,viewMode,5,5.2)%>
              <%=fb.select("tipo_val_mpdl"+i,"M=$,P=%",des.getTipoValMpdl())%></td>
              
            </tr>
            </table>
            </div>
            </td>
          
            </tr>
<%
  }     
fb.appendJsValidation("if(error>0)doAction();");
%>
        <tr class="TextRow02">
          <td align="right" colspan="14">
            <cellbytelabel id="18">Opciones de Guardar</cellbytelabel>: 
            <!--<%=fb.radio("saveOption","N")%>Crear Otro --->
            <%=fb.radio("saveOption","O",true,viewMode,false)%><cellbytelabel id="19">Mantener Abierto </cellbytelabel>
            <%=fb.radio("saveOption","C",false,viewMode,false)%><cellbytelabel id="20">Cerrar</cellbytelabel> 
            <%=fb.submit("save","Guardar",true,viewMode,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
            <%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
          </td>
        </tr>
      
<%=fb.formEnd(true)%>
    </table>
</div>
<!-- MAIN DIV END HERE -->
</div>    
<script type="text/javascript">
<%
String tabLabel = "'Datos Generales'";
if (!mode.equalsIgnoreCase("add"))
 tabLabel += ",'Dignostico y Procedimientos','Cobertura'";
%>
 initTabs('dhtmlgoodies_tabView1',Array(<%=tabLabel%>),<%=tab%>,'100%','');
</script>
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
  String itemRemoved = "";
  String revomeVector ="";
  empresa=request.getParameter("empresa");  
  DatosSolicitud ds = new DatosSolicitud();
  ds.setEmpresa(empresa);
  ds.setPacId(request.getParameter("pac_id"));
  ds.setFechaNacimiento(request.getParameter("fecha_nacimiento"));
  ds.setPaciente(request.getParameter("cod_pac"));
  ds.setAdmision(request.getParameter("admision"));
  if (tab.equals("0")) //datos generales
  {
        ds.setFecha(request.getParameter("fecha"));
        ds.setPoliza(request.getParameter("poliza"));
        if(request.getParameter("certificado")!= null && !request.getParameter("certificado").equals("")) ds.setCertificado(request.getParameter("certificado"));
				else ds.setCertificado(".");//Deepak pidio que se pusiera un punto porque el campo es obligatorio 20101221
        ds.setPropietarioDePoliza(request.getParameter("dueño"));
        ds.setPagadaHasta(request.getParameter("pagada_hasta"));
        ds.setTipoPoliza(request.getParameter("tipo_poliza"));
        ds.setObservaciones(request.getParameter("observaciones"));
        ds.setCoPago(request.getParameter("coPago"));
        ds.setDiaEvento(request.getParameter("diaEvento"));
        ds.setEstatus(request.getParameter("estatus"));
        if (request.getParameter("usuario_adiciona")==null || request.getParameter("usuario_adiciona").trim().equals(""))
        ds.setUsuarioAdiciona((String) session.getAttribute("_userName"));
        else
        ds.setUsuarioAdiciona(request.getParameter("usuario_adiciona"));
        ds.setFechaAdiciona(request.getParameter("fecha_adiciona"));
        ds.setUsuarioModifica((String) session.getAttribute("_userName"));
        ds.setFechaModifica(cDateTime);
        ds.setDiasHosp(request.getParameter("diasHosp"));
        ds.setTipoValor(request.getParameter("tipoValor"));
        ds.setDiasCopago(request.getParameter("diasCopago"));
        ds.setPase(request.getParameter("pase"));
        ds.setPaseK(request.getParameter("pase_k"));
        if (mode.equalsIgnoreCase("add"))
        {
          ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
          SBMgr.add(ds);
          secuencia = SBMgr.getPkColValue("secuencia");
          ds.setSecuencia(secuencia);
          ConMgr.clearAppCtx(null);
        }
        else
        {
          ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
          secuencia =request.getParameter("solicitudNo");
          ds.setSecuencia(request.getParameter("solicitudNo"));
          SBMgr.update(ds);
          ConMgr.clearAppCtx(null);
        }
  }
  if (tab.equals("1")) //Diagnosticos y Procedimientos
  {
        int size = 0;
        if (request.getParameter("diagSize") != null) size = Integer.parseInt(request.getParameter("diagSize"));
        al.clear();
        ds.setSecuencia(request.getParameter("solicitud"));
        for (int i=0; i<size; i++)
        {   
              ds.setEmpresa(empresa);
              DetalleSolicitud det= new DetalleSolicitud();
              det.setSolicitud(request.getParameter("solicitud"));
              det.setSecuencia(request.getParameter("secuencia"+i));
              det.setTipoDetalle(request.getParameter("tipo_detalle"+i));
              
              if(request.getParameter("tipo_detalle"+i) != null && request.getParameter("tipo_detalle"+i).trim().equals("D"))
              {
                det.setDiagnostico(request.getParameter("codigo"+i));
                det.setDescripcion(request.getParameter("descDiagnostico"+i));
                vDiagSol.add(request.getParameter("codigo"+i));
              }
              else
              {
                 det.setProcedimiento(request.getParameter("codigo"+i));
                 det.setDescripcion(request.getParameter("descDiagnostico"+i));
                 vDiagSol.add(request.getParameter("codigo"+i));
              }
              det.setUsuarioCreacion(request.getParameter("usuario_creacion"+i));
              det.setUsuarioModificacion((String) session.getAttribute("_userName"));
              det.setFechaCreacion(request.getParameter("fecha_creacion"+i));
              det.setFechaModificacion(cDateTime);
              det.setPaseK(request.getParameter("pase_k"+i));
              det.setKey(request.getParameter("key"+i));
              det.setCodigo(request.getParameter("codigo"+i));
              key=request.getParameter("key"+i);
              
          if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
          {
            itemRemoved = det.getKey();  
            if(det.getProcedimiento() != null && !det.getProcedimiento().trim().equals(""))
              revomeVector = det.getProcedimiento();
            else revomeVector = det.getDiagnostico();
                
          }
          else
          {
            try
            { 
              al.add(det);
              iDiagSol.put(key,det);
              ds.addDetalleSol(det);
            }
            catch(Exception e)
            {
              System.err.println(e.getMessage());
            }
          }//End else 
      }//for
      
      if(!itemRemoved.equals(""))
      { 
        vDiagSol.remove(revomeVector);
        iDiagSol.remove(itemRemoved);
          response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&diagLastLineNo="+diagLastLineNo+"&coLastLineNo="+coLastLineNo+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&cod_pac="+request.getParameter("cod_pac")+"&pac_id="+request.getParameter("pac_id")+"&secuencia="+request.getParameter("solicitud")+"&empresa="+request.getParameter("empresa")+"&admision="+request.getParameter("admision"));
        return;
      }
      if(baction.equals("+"))//Agregar
      { 
        
        DetalleSolicitud det = new DetalleSolicitud();
        det.setSecuencia("0");
        det.setFechaCreacion(cDateTime);
        det.setUsuarioCreacion((String) session.getAttribute("_userName"));
        det.setTipoDetalle("P");
        diagLastLineNo++;
        if (diagLastLineNo < 10) key = "00" +diagLastLineNo;
        else if (diagLastLineNo < 100) key = "0" +diagLastLineNo;
        else key = "" +diagLastLineNo;
        det.setKey(key);
        try
        {
            iDiagSol.put(key,det);
        }
        catch(Exception e)
        {
            System.err.println(e.getMessage());
        }
        
        response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&diagLastLineNo="+diagLastLineNo+"&coLastLineNo="+coLastLineNo+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&cod_pac="+request.getParameter("cod_pac")+"&pac_id="+request.getParameter("pac_id")+"&secuencia="+request.getParameter("solicitud")+"&empresa="+request.getParameter("empresa")+"&admision="+request.getParameter("admision"));
        return;
      } 

      if (baction.equalsIgnoreCase("Guardar"))
      {
          
         ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
         SBMgr.detalle(ds);
         secuencia =request.getParameter("solicitud");
         ConMgr.clearAppCtx(null);
      }
  }
  
  if (tab.equals("2")) //cobertura
  {     
        
        int coSize = 0;
        if (request.getParameter("coSize") != null) coSize = Integer.parseInt(request.getParameter("coSize"));
        al.clear();
        for (int i=0; i<coSize; i++)
        {   
        DetalleSolicitud detCob = new DetalleSolicitud();
        detCob.setClasificaCober(request.getParameter("clasifica_cober"+i));
        detCob.setMonto(request.getParameter("monto"+i));
        detCob.setTipoValor(request.getParameter("tipo_valor"+i));
        detCob.setDeducible(request.getParameter("deducible"+i));
        detCob.setMtoExcedente(request.getParameter("mto_excedente"+i));
        detCob.setTipoValExcedente(request.getParameter("tipo_val_excedente"+i));
        detCob.setMtoPacExcedente(request.getParameter("mto_pac_excedente"+i));
        detCob.setTipoValPac(request.getParameter("tipo_val_pac"+i));
        detCob.setUsuarioCreacion(request.getParameter("usuario_creacion"+i));
        detCob.setUsuarioModificacion((String) session.getAttribute("_userName"));
        detCob.setFechaCreacion(request.getParameter("fecha_creacion"+i));
        detCob.setFechaModificacion(cDateTime);
        detCob.setSecuencia(request.getParameter("secuencia"+i));
        if(request.getParameter("empresa").trim().equals("2"))
        {
          detCob.setMontoCliDetLim(request.getParameter("monto_cli_det_lim"+i));
          detCob.setMontoEmpDetLim(request.getParameter("monto_emp_det_lim"+i));
          detCob.setMontoPacDetLim(request.getParameter("monto_pac_det_lim"+i));
          detCob.setTipoValMcdl(request.getParameter("tipo_val_mcdl"+i));
          detCob.setTipoValMedl(request.getParameter("tipo_val_medl"+i));
          detCob.setTipoValMpdl(request.getParameter("tipo_val_mpdl"+i));
        }
        detCob.setPase(request.getParameter("pase"+i));
        detCob.setPaseK(request.getParameter("pase_k"+i));
        if(request.getParameter("gasto_no_cubierto"+i)!=null)
        detCob.setGastoNoCubierto("S");
        else detCob.setGastoNoCubierto("N");
        detCob.setTipoHabitacion(request.getParameter("tipo_habitacion"+i));
        
        detCob.setKey(request.getParameter("key"+i)); 
        
        detCob.setDeducAntesPago(request.getParameter("deduc_antes_pago"+i));
        detCob.setDeducibleAcumulado(request.getParameter("deducible_acumulado"+i));
        detCob.setMontoAcumulado(request.getParameter("monto_acumulado"+i));
        detCob.setLimiteAcumHon(request.getParameter("limite_acum_hon"+i));
        detCob.setLimiteAcumMisc(request.getParameter("limite_acum_misc"+i));
        
        key = request.getParameter("key"+i);
    if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
    {
      itemRemoved = detCob.getKey();  
      detCob.setStatus("D");  

    }
    else detCob.setStatus(request.getParameter("status"+i));  
    
      try
      { 
        al.add(detCob);
        iCobsol.put(key,detCob);  
        ds.addCoberturaSol(detCob);
      }
      catch(Exception e)
      {
        System.err.println(e.getMessage());
      }
    
  }//for

  if (!itemRemoved.equals(""))
  { 
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&diagLastLineNo="+diagLastLineNo+"&coLastLineNo="+coLastLineNo+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&cod_pac="+request.getParameter("cod_pac")+"&pac_id="+request.getParameter("pac_id")+"&secuencia="+request.getParameter("solicitud")+"&empresa="+request.getParameter("empresa")+"&admision="+request.getParameter("admision"));
    return;
  }

  if (baction.equals("+"))//Agregar
  {
    DetalleSolicitud detCob = new DetalleSolicitud();
    
    detCob.setSecuencia("0");
    detCob.setUsuarioCreacion((String) session.getAttribute("_userName"));
    detCob.setFechaCreacion(cDateTime);
    detCob.setClasificaCober("3");
    detCob.setGastoNoCubierto("N");
    coLastLineNo++;
    if (coLastLineNo < 10) key = "00" + coLastLineNo;
    else if (coLastLineNo < 100) key = "0" + coLastLineNo;
    else key = "" + coLastLineNo;
    detCob.setKey(key);
    try
    {
      iCobsol.put(key, detCob);
    }
    catch(Exception e)
    {
      System.err.println(e.getMessage());
    }
    response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab="+tab+"&mode="+mode+"&diagLastLineNo="+diagLastLineNo+"&coLastLineNo="+coLastLineNo+"&fecha_nacimiento="+request.getParameter("fecha_nacimiento")+"&cod_pac="+request.getParameter("cod_pac")+"&pac_id="+request.getParameter("pac_id")+"&secuencia="+request.getParameter("solicitud")+"&empresa="+request.getParameter("empresa")+"&admision="+request.getParameter("admision"));
    return;
  } 

  if (baction.equalsIgnoreCase("Guardar"))
  {
    
    ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
    secuencia =request.getParameter("solicitud");
    ds.setSecuencia(secuencia);
    SBMgr.coberturaSol(ds);
    ConMgr.clearAppCtx(null);
        
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
if (SBMgr.getErrCode().equals("1"))
{
%>
  alert('<%=SBMgr.getErrMsg()%>');
<%
  if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/admision/solicitud_beneficio.jsp"))
    {
%>
  //window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/admision/solicitud_beneficio.jsp")%>';
<%
    }
    else
    {
%>
  //window.opener.location = '<%=request.getContextPath()%>/admision/solicitud_beneficio.jsp';
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
} else throw new Exception(SBMgr.getErrMsg());
%>
} 

function addMode()
{
  window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&pac_id=<%=pac_id%>&tab=<%=tab%>&secuencia=<%=secuencia%>&fecha_nacimiento=<%=fecha_nacimiento%>&cod_pac=<%=cod_pac%>&admision=<%=admision%>&empresa=<%=empresa%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>