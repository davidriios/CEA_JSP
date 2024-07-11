<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.residencial.DetallePlan"%>
<%@ page import="issi.residencial.ResAdmision"%>
<%@ page import="issi.residencial.Custodio"%>
<%@ page import="issi.residencial.Suplente"%>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="cdo" scope="page" class="issi.admin.CommonDataObject" />
<jsp:useBean id="iHab" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vHab" scope="session" class="java.util.Vector" />
<jsp:useBean id="iSuple" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vSuple" scope="session" class="java.util.Vector" />
<jsp:useBean id="iMedi" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMedi" scope="session" class="java.util.Vector" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ResAdmision adm = new ResAdmision();
DetallePlan pl = new DetallePlan();
Custodio cus = new Custodio();
Suplente spl = new Suplente();
CommonDataObject acomp = new CommonDataObject();
CommonDataObject rel = new CommonDataObject();
CommonDataObject serv = new CommonDataObject();
CommonDataObject medic = new CommonDataObject();

ArrayList al = new ArrayList();
ArrayList pList = new ArrayList();
ArrayList cList = new ArrayList();
ArrayList mList = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String mode = request.getParameter("mode");
String modeAdm = request.getParameter("modeAdm");
String modeCust = request.getParameter("modeCust");
String modeAcomp = request.getParameter("modeAcomp");
String modeRel = request.getParameter("modeRel");
String modeServ = request.getParameter("modeServ");
String prov = request.getParameter("prov");
String sigla = request.getParameter("sigla");
String tomo = request.getParameter("tomo");
String asiento = request.getParameter("asiento");
String change = request.getParameter("change");
int count = 0;
int countSuple = 0;
int countAcomp = 0;
int countRel = 0;
int countServ = 0;
int pLastLineNo = 0;
int cLastLineNo = 0;
int mLastLineNo = 0;

if (tab == null) tab = "0";
if (mode == null) mode = "add";
if (modeAdm == null) modeAdm = "add";
if (modeCust== null) modeCust = "add";
if (modeAcomp== null) modeAcomp = "add";
if (modeRel== null) modeRel = "add";
if (change!= null && !change.equals("")) change = request.getParameter("change");
if (request.getParameter("mLastLineNo")!=null) mLastLineNo = Integer.parseInt(request.getParameter("mLastLineNo")); 
if (request.getParameter("pLastLineNo")!=null) pLastLineNo = Integer.parseInt(request.getParameter("pLastLineNo"));
if (request.getParameter("cLastLineNo")!=null) cLastLineNo = Integer.parseInt(request.getParameter("cLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
	if (mode.equalsIgnoreCase("add"))
	{  
	   if (change == null)
       {
	   iHab.clear(); 
	   vHab.clear();
	   iSuple.clear(); 
	   vSuple.clear(); 
	   iMedi.clear(); 
	   vMedi.clear(); 
	   prov = "0";
	   sigla = "0";
	   tomo = "0";
	   asiento = "0";
	   cdo.addColValue("fechaNac","");	
	   }  	
	}
	else
	{
	    if (change == null)
        {
	      iHab.clear(); 
	      vHab.clear(); 
		  iSuple.clear(); 
	      vSuple.clear(); 
		  iMedi.clear(); 
	      vMedi.clear(); 
	    }
		if (prov == null) throw new Exception("El Código de Provincia no es válido. Por favor intente nuevamente!");
		if (sigla == null) throw new Exception("El Código de Sigla no es válido. Por favor intente nuevamente!");
		if (tomo == null) throw new Exception("El Código de Tomo no es válido. Por favor intente nuevamente!");
		if (asiento == null) throw new Exception("El Código de Asiento no es válido. Por favor intente nuevamente!");

		sql = "SELECT a.compania, a.provincia, a.sigla, a.tomo, a.asiento, nvl(a.primer_apellido,' ') as primerApellido, nvl(a.segundo_apellido,' ') as segundoApellido, nvl(a.apellido_casada,' ') as apellidoCasada, nvl(a.sexo,' ') as sexo, nvl(to_char(a.fecha_nac,'dd/mm/yyyy'),' ') as fechaNac, nvl(a.estado_civil,' ') as estadoCivil, nvl(a.direccion,' ') as direccion, nvl(a.telefono,' ') as telefono, nvl(a.estado,' ') as estado, nvl(a.fallecido,' ') as fallecido, nvl(a.seguro_social,' ') as seguroSocial, decode(a.religion,null,' ',a.religion) as religion, nvl(c.descripcion,' ') as religionDesc, decode(a.nacionalidad,null,' ',a.nacionalidad) as nacionalidad, nvl(b.nombre,' ') as nacionalidadDesc, nvl(a.observaciones,' ') as observaciones, decode(a.edad,null,' ',a.edad) as edad, nvl(a.primer_nombre,' ') as primerNombre, nvl(a.segundo_nombre,' ') as segundoNombre, nvl(a.lugar_nac,' ') as lugarNac, decode(a.ingreso_fam,null,' ',a.ingreso_fam) as ingresoFam, decode(a.saldo,null,' ',a.saldo) as saldo, decode(a.saldo_empieza,null,' ',a.saldo_empieza) as saldoEmpieza FROM tbl_res_residente a, tbl_sec_pais b, tbl_adm_religion c WHERE a.nacionalidad=b.codigo and a.religion=c.codigo and a.provincia="+prov+" and a.sigla='"+sigla+"' and a.tomo="+tomo+" and a.asiento="+asiento+" and a.compania="+(String) session.getAttribute("_companyId");
		
		cdo = SQLMgr.getData(sql);
			
		sql = "SELECT a.provincia, a.sigla, a.tomo, a.asiento, a.secuencia, nvl(to_char(a.fecha_ingreso,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaIngreso, nvl(to_char(a.fecha_egreso,'dd/mm/yyyy hh24:mi:ss'),' ') as fechaEgreso, nvl(a.estado,' ') as estado, nvl(a.medico_ref_id,' ') as medicoRefId, nvl(a.medico_ref_nombre,' ') as medicoRefNombre, nvl(a.medico_ref_tel,' ') as medicoRefTel,  nvl(a.observaciones,' ') as observaciones, nvl(a.alergias,' ') as alergias, nvl(a.diagnostico,' ') as diagnostico, decode(a.aseguradora,null,' ',a.aseguradora) as aseguradora, nvl(b.nombre,' ') as aseguradoraDesc, nvl(a.poliza,' ') as poliza FROM tbl_res_admision a, tbl_adm_empresa b WHERE a.aseguradora=b.codigo(+) and a.provincia="+prov+" and a.sigla='"+sigla+"' and a.tomo="+tomo+" and a.asiento="+asiento+" and a.compania="+(String) session.getAttribute("_companyId");		
		
		count = CmnMgr.getCount(sql);	
		if (count>0)
		{
		  modeAdm = "edit";

		  adm = (ResAdmision) sbb.getSingleRowBean(ConMgr.getConnection(),sql, ResAdmision.class);	
		  
	  	  sql = "SELECT a.secuencia, a.admision, a.asiento, a.tomo, a.sigla, a.provincia, a.compania, nvl(a.habitacion,' ') as habitacion, nvl(a.cama,' ') as cama, decode(a.planes,null,' ',a.planes) as planes, nvl(b.descripcion,' ') as planesDesc, decode(a.tipo_hab,null,' ',a.tipo_hab) as tipoHab, nvl(c.descripcion,' ') as tipoHabDesc, nvl(a.estado,' ') as estado, decode(a.descuento,null,' ',a.descuento) as descuento, a.planes||'-'||a.tipo_hab as planHabit FROM tbl_res_hab_x_cama a, tbl_res_planes b, tbl_res_tipo_habitacion c WHERE a.planes=b.codigo(+) and a.tipo_hab=c.secuencia(+) and a.provincia="+prov+" and a.sigla='"+sigla+"' and a.tomo="+tomo+" and a.asiento="+asiento+" and a.compania="+(String) session.getAttribute("_companyId")+" and admision ="+adm.getSecuencia();
	       
		  pList = sbb.getBeanList(ConMgr.getConnection(), sql, DetallePlan.class);
	      pLastLineNo = pList.size(); 	
		
		  for (int i = 1; i <= pList.size(); i++)
	      {		    
		    pl = (DetallePlan) pList.get(i-1);

		    if (i < 10) key = "00" + i;
		    else if (i < 100) key = "0" + i;
		    else key = "" + i;
		    pl.setKey(key);

		    try
		    {
			   iHab.put(key,pl);
			   vHab.addElement(pl.getPlanHabit());		
		    }
		    catch(Exception e)
		    {
			   System.err.println(e.getMessage());
		    }
	      }	
		  
		  sql = "SELECT a.secuencia, a.admision, a.asiento_r as asientoR, a.tomo_r as tomoR, a.sigla_r as siglaR, a.provincia_r as provinciaR, a.cia_r as ciaR, a.identificacion, nvl(to_char(a.f_nacimiento,'dd/mm/yyyy hh24:mi:ss'),' ') as fNacimiento, nvl(a.primer_apellido,' ') as primerApellido, nvl(a.apellido_casada,' ') as apellidoCasada, nvl(a.segundo_apellido,' ') as segundoApellido, nvl(a.estado,' ') as estado, nvl(a.direccion,' ') as direccion, nvl(a.sexo,' ') as sexo, nvl(a.parentesco,' ') as parentesco, nvl(a.ocupacion,' ') as ocupacion, nvl(a.telefono_casa,' ') as telefonoCasa, nvl(a.telefono_oficina,' ') as telefonoOficina, nvl(a.fax,' ') as fax, nvl(a.celular,' ') as celular, nvl(a.apartado,' ') as apartado, nvl(a.email,' ') as email, nvl(a.observaciones,' ') as observaciones, nvl(a.empresa,' ') as empresa, nvl(a.primer_nombre,' ') as primerNombre, nvl(a.segundo_nombre,' ') as segundoNombre FROM tbl_res_custodio a WHERE a.admision ="+adm.getSecuencia()+" and a.asiento_r ="+asiento+" and a.tomo_r ="+tomo+" and a.sigla_r ="+sigla+" and a.provincia_r ="+prov+" and a.cia_r="+(String) session.getAttribute("_companyId");		  
		  
		  countSuple = CmnMgr.getCount(sql);
		  if ( countSuple > 0)
		  {	
		     modeCust = "edit";		  

		     cus = (Custodio) sbb.getSingleRowBean(ConMgr.getConnection(),sql, Custodio.class);	
		   			  
		     sql = "SELECT identificacion, cia, provincia, sigla, tomo, asiento, admision, nvl(to_char(f_nacimiento,'dd/mm/yyyy hh24:mi:ss'),' ') as fNacimiento, nvl(nombres,' ') as nombres, nvl(apellidos,' ') as apellidos, nvl(parentesco,' ') as parentesco, nvl(telefono_casa,' ') as telefonoCasa, nvl(telefono_oficina,' ') as telefonoOficina, nvl(telefono_celular,' ') as telefonoCelular, nvl(estado,' ') as estado, nvl(observaciones,' ') as observaciones, secuencia, sec_custodio as secCustodio FROM tbl_res_cus_suplente WHERE admision ="+adm.getSecuencia()+" and asiento ="+asiento+" and tomo ="+tomo+" and sigla ="+sigla+" and provincia ="+prov+" and cia ="+(String) session.getAttribute("_companyId")+" and sec_custodio ="+cus.getSecuencia();
    
		     cList = sbb.getBeanList(ConMgr.getConnection(), sql, Suplente.class);
	         cLastLineNo = cList.size(); 	
		
		     for (int i = 1; i <= cList.size(); i++)
	         {		    
		       spl = (Suplente) cList.get(i-1);

		       if (i < 10) key = "00" + i;
		       else if (i < 100) key = "0" + i;
		       else key = "" + i;
		       spl.setKey(key);

		       try
		       {
			     iSuple.put(key,spl);
			     vSuple.addElement(spl.getSecuencia());		
		       }
		       catch(Exception e)
		       {
			     System.err.println(e.getMessage());
		       }
	         }
		  }	
		  	
		  
		  sql = "SELECT secuencia, admision, asien_r as asienR, tomo_r as tomoR, sigla_r as siglaR, provi_r as proviR, cia, nvl(identificacion,' ') as identificacion, nvl(nombres,' ') as nombres, nvl(apellidos,' ') as apellidos, nvl(per_urgencia,' ') as perUrgencia, nvl(tel_urgencia,' ') as telUrgencia, nvl(telefono_casa,' ') as telefonoCasa, nvl(telefono_celular,' ') as telefonoCelular, estado, nvl(direccion,' ') as direccion, nvl(educacion,' ') as educacion, nvl(observaciones,' ') as observaciones FROM tbl_res_acompanante WHERE admision = "+adm.getSecuencia()+" and asien_r = "+asiento+" and tomo_r = "+tomo+" and sigla_r = "+sigla+" and provi_r = "+prov+" and cia = "+(String) session.getAttribute("_companyId"); 	  
		 
		  countAcomp = CmnMgr.getCount(sql);	
		  
		  if ( countAcomp > 0)
          {
		     modeAcomp = "edit";
			 
			 acomp = SQLMgr.getData(sql);	       
		  }			  
		  
		  sql = "SELECT a.admision, a.asiento, a.tomo, a.sigla, a.provincia, a.compania, nvl(a.observacion,' ') as observacion, nvl(a.responsable,"+cus.getSecuencia()+") as responsable, nvl(a.nrf,' ') as nrf, nvl(a.nth,' ') as nth, nvl(a.nah,' ') as nah, nvl(a.ndm,' ') as ndm, nvl(a.nmt,' ') as nmt, nvl(a.ngp,' ') as ngp, nvl(a.cus_res_fam,' ') as cusResFam, nvl(to_char(fecha,'dd/mm/yyyy hh24:mi:ss'),' ') as fecha, nvl(a.testigo,' ') as testigo, b.primer_nombre||' '||b.primer_apellido as residente FROM tbl_res_relevo a, tbl_res_residente b WHERE a.asiento=b.asiento and a.tomo=b.tomo and a.sigla=b.sigla and a.provincia=b.provincia and a.compania=b.compania and a.admision = "+adm.getSecuencia()+" and a.asiento="+asiento+" and a.tomo="+tomo+" and a.sigla="+sigla+" and a.provincia="+prov+" and a.compania="+(String) session.getAttribute("_companyId"); 
		  		  		 
		  countRel = CmnMgr.getCount(sql);	
		  
		  if ( countRel > 0)
          {
		     modeRel = "edit"; 
			 	
			 rel = SQLMgr.getData(sql);			       
		  }
		  else
		  {
		      rel.addColValue("responsable",cus.getPrimerNombre()+" "+cus.getPrimerApellido());
			  rel.addColValue("residente",cdo.getColValue("PrimerNombre")+" "+cdo.getColValue("PrimerApellido"));
		  }	
		  
		  sql = "SELECT provincia, sigla, tomo, asiento, admision, nvl(ausf,' ') as ausf, nvl(ames,' ') as ames, nvl(exal,' ') as exal, nvl(radi,' ') as radi, nvl(fisi,' ') as fisi, nvl(eort,' ') as eort, nvl(medi,' ') as medi, nvl(alen,' ') as alen, nvl(refr,' ') as refr, nvl(sepe,' ') as sepe, nvl(sepo,' ') as sepo, nvl(arec,' ') as arec, compania, nvl(observaciones,' ') as observaciones FROM tbl_res_servicios WHERE admision = "+adm.getSecuencia()+" and asiento="+asiento+" and tomo="+tomo+" and sigla="+sigla+" and provincia="+prov+" and compania="+(String) session.getAttribute("_companyId");	 
		  
		  countServ = CmnMgr.getCount(sql);	
		  
		  if ( countServ > 0)
          {
		     modeServ = "edit"; 
			 	
			 serv = SQLMgr.getData(sql);			       
		  } 
		  
		  if (change == null)
          {
		     sql = "SELECT compania, provincia, sigla, tomo, asiento, med_ref_id||'-'||med_espec_ini as medicEspec, med_ref_id, nvl(med_especialid,' ') as med_especialid, nvl(med_espec_ini,'0') as med_espec_ini, nvl(med_ref_nombre,' ') as med_ref_nombre, nvl(med_ref_tel,' ') as med_ref_tel FROM tbl_res_med_residente WHERE admision = "+adm.getSecuencia()+" and asiento="+asiento+" and tomo="+tomo+" and sigla="+sigla+" and provincia="+prov+" and compania="+(String) session.getAttribute("_companyId");  
		  
		    mList = SQLMgr.getDataList(sql);
		    			
			mLastLineNo = mList.size();
		    for (int i=1; i<=mList.size(); i++)
		    {
			   CommonDataObject med = (CommonDataObject) mList.get(i-1);

 			   if (i < 10) key = "00" + i;
			   else if (i < 100) key = "0" + i;
			   else key = "" + i;
			   med.addColValue("key",key);

			   try
			   {
				  iMedi.put(key,med);
				  vMedi.addElement(med.getColValue("medicEspec"));
			   }
			   catch(Exception e)
			   {
				  System.err.println(e.getMessage());
			   } 
		    } 
		  }	
		   
		}
	}
%>
<html> 
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Residente -  Edición - '+document.title;

function addNacional()
{
   abrir_ventana1('../rhplanilla/list_pais.jsp?id=5');
}
function addReligion()
{
   abrir_ventana1('paciente_religion_list.jsp?id=2');
}
function addAseguradora()
{
   abrir_ventana1('../common/search_empresa.jsp?fp=resAdmision');
}
function addMedico()
{
   abrir_ventana1('../common/search_medico.jsp?fp=resAdmision');
}
function saveMethod(index)
{  
   switch (index)
   {
      case 1: 
		   window.frames['itemFrame1'].document.form1.baction.value = "Guardar";
		   window.frames['itemFrame1'].doSubmit();
	  break;
	  
	  case 2: 	   
	       window.frames['itemFrame2'].document.form2.baction.value = "Guardar";
		   window.frames['itemFrame2'].doSubmit();
	  break;
   } 	   	   
}
function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}
function doAction()
{
<%
	if (request.getParameter("type") != null)
	{
		if (tab.equals("4"))
		{
%>
 	showMedico();
<%
        }
	}
%>	
function showMedico()
{
   abrir_ventana1('../common/check_medico.jsp?fp=doctoresResid&tab=4&mode=<%=mode%>&prov=<%=prov%>&asiento=<%=asiento%>&tomo=<%=tomo%>&sigla=<%=sigla%>&mLastLineNo=<%=mLastLineNo%>');
}	
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="RESIDENCIAL - MANTENIMIENTO"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="100%" cellpadding="5" cellspacing="0">
		<tr>
			<td>

<!-- MAIN DIV START HERE -->
<div id="dhtmlgoodies_tabView1">


<!-- TAB0 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form0",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","0")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(0)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Principal</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus0" style="display:none">+</label><label id="minus0">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel0">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
						<tr class="TextRow01">
							<td width="10%">Nombre</td>
					        <td width="58%"><%=fb.textBox("primerNombre",cdo.getColValue("primerNombre"),false,false,false,38,30)%><%=fb.textBox("segundoNombre",cdo.getColValue("segundoNombre"),false,false,false,38,30)%></td>
							<td width="8%">C&eacute;dula</td>
							<td width="24%"><%=fb.textBox("provincia",cdo.getColValue("provincia"),false,false,false,3,2)%><%=fb.textBox("sigla",cdo.getColValue("sigla"),false,false,false,3,2)%><%=fb.textBox("tomo",cdo.getColValue("tomo"),false,false,false,5,5)%><%=fb.textBox("asiento",cdo.getColValue("asiento"),false,false,false,5,5)%></td>
						</tr>					
						<tr class="TextRow01">
							<td>Apellido</td>
							<td><%=fb.textBox("primerApellido",cdo.getColValue("primerApellido"),false,false,false,24,50)%><%=fb.textBox("segundoApellido",cdo.getColValue("segundoApellido"),false,false,false,24,50)%><%=fb.textBox("apellidoCasada",cdo.getColValue("apellidoCasada"),false,false,false,23,50)%></td>
							<td>Compa&ntilde;ia</td>
							<td><%=fb.intBox("compania",cdo.getColValue("compania"),true,false,false,31,5)%></td>														
						</tr>				
						</table>
					</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(1)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Generales</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus1" style="display:none">+</label><label id="minus1">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel1">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">	
						<tr class="TextRow01">
							<td width="10%">Nacionalidad</td>
							<td width="58%"><%=fb.intBox("nacionalidad",cdo.getColValue("nacionalidad"),false,false,true,10)%><%=fb.textBox("nacionalidadDesc",cdo.getColValue("nacionalidadDesc"),false,false,true,66,30)%><%=fb.button("btnNacional","...",true,false,null,null,"onClick=\"javascript:addNacional()\"")%></td>
							<td width="10%">Fecha Nac.</td>
							<td width="22%"><jsp:include page="../common/calendar.jsp" flush="true">
											<jsp:param name="noOfDateTBox" value="1" />
											<jsp:param name="clearOption" value="true" />
											<jsp:param name="nameOfTBox1" value="fechaNac" />
											<jsp:param name="valueOfTBox1" value="<%=cdo.getColValue("fechaNac")%>" />
											</jsp:include></td>																	
						</tr>
						<tr class="TextRow01">
							<td>Lugar Nac.</td>
							<td><%=fb.textBox("lugarNac",cdo.getColValue("lugarNac"),false,false,false,82,50)%></td>
							<td>Edad</td>
							<td><%=fb.intBox("edad",cdo.getColValue("edad"),false,false,false,20,5)%></td>
						</tr>
						<tr class="TextRow01">
						    <td>Dir. Previa</td>
							<td><%=fb.textBox("direccion",cdo.getColValue("direccion"),false,false,false,82,200)%></td>
							<td>Seguro Social</td>
							<td><%=fb.textBox("seguroSocial",cdo.getColValue("seguroSocial"),false,false,false,20,20)%></td>							
						</tr>		
						<tr class="TextRow01">
							<td>Religi&oacute;n</td>
							<td><%=fb.intBox("religion",cdo.getColValue("religion"),false,false,true,10)%><%=fb.textBox("religionDesc",cdo.getColValue("religionDesc"),false,false,true,66,30)%><%=fb.button("btnReligion","...",true,false,null,null,"onClick=\"javascript:addReligion()\"")%></td>
							<td>Estado Civil</td>
							<td><%=fb.select("estadoCivil","S=Soltero,C=Casado,V=Viudo,D=Divorciados,O=Otros",cdo.getColValue("estado"))%></td>
						</tr>
						<tr class="TextRow01">
						    <td>Tel&eacute;fono</td>
							<td><%=fb.textBox("telefono",cdo.getColValue("telefono"),false,false,false,30,10)%></td>
							<td>Sexo</td>
							<td><%=fb.select("sexo","M=Masculino,F=Femenino",cdo.getColValue("sexo"))%></td>							
						</tr>
						<tr class="TextRow01">
						    <td>Ingreso Fam.</td>
							<td><%=fb.decBox("ingresoFam",cdo.getColValue("ingresoFam"),false,false,false,30,12)%></td>							
							<td>Fallecido</td>
							<td><%=fb.select("fallecido","N=No,S=Si",cdo.getColValue("fallecido"))%></td>
						</tr>
						<tr class="TextRow01">
							<td>Saldo</td>
							<td><%=fb.decBox("saldo",cdo.getColValue("saldo"),false,false,false,30,10)%></td>
							<td>Saldo Hist&oacute;rico</td>
							<td><%=fb.decBox("saldoEmpieza",cdo.getColValue("saldoEmpieza"),false,false,false,20,10)%></td>							
						</tr>
						<tr class="TextRow01">
							<td>Observaci&oacute;n</td>
							<td colspan="3"><%=fb.textarea("observaciones",cdo.getColValue("observaciones"),false,false,false,62,5)%></td>
						</tr>					
						</table>
					</td>
				</tr>

				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false)%>
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

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("modeAdm",modeAdm)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
<%=fb.hidden("keySize",""+iHab.size())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(10)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Admisi&oacute;n Del Residente</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel10">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="10%">No.</td>
								<td width="42%"><%=fb.textBox("secuencia",adm.getSecuencia(),false,false,true,40)%></td>														
								<td width="8%">Estado</td>
								<td width="40%"><%=fb.select("estado","A=Activo,I=Inactivo",adm.getEstado())%></td>																						
							</tr>					
							<tr class="TextRow01">
								<td>Ingreso</td>
								<td><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fechaIngreso" />									
									<jsp:param name="valueOfTBox1" value="<%=(adm.getFechaIngreso()==null)?"":adm.getFechaIngreso()%>" />
									</jsp:include>
								<td>Egreso</td>
								<td><jsp:include page="../common/calendar.jsp" flush="true">
									<jsp:param name="noOfDateTBox" value="1" />
									<jsp:param name="nameOfTBox1" value="fechaEgreso" />									
									<jsp:param name="valueOfTBox1" value="<%=(adm.getFechaEgreso()==null)?"":adm.getFechaEgreso()%>" />
									</jsp:include>
							</tr>						
							<tr class="TextRow01">
								<td>Alergias</td>
								<td><%=fb.textBox("alergias",adm.getAlergias(),false,false,false,40,300)%></td>
								<td>Diagn&oacute;stico</td>
								<td><%=fb.textBox("diagnostico",adm.getDiagnostico(),false,false,false,40,1000)%></td>
							</tr>
							<tr class="TextRow01">							
								<td>M&eacute;dico</td>
								<td><%=fb.intBox("medicoRefId",adm.getMedicoRefId(),false,false,true,5,15)%><%=fb.textBox("medicoRefNombre",adm.getMedicoRefNombre(),false,false,true,40,100)%><%=fb.button("btnMedico","...",true,false,null,null,"onClick=\"javascript:addMedico()\"")%></td>
								<td>Tel&eacute;fono</td>
								<td><%=fb.textBox("medicoRefTel",adm.getMedicoRefTel(),false,false,true,40,10)%></td>													
							</tr>
							<tr class="TextRow01">							
								<td>Aseguradora</td>
								<td><%=fb.intBox("aseguradora",adm.getAseguradora(),false,false,true,5,5)%><%=fb.textBox("aseguradoraDesc",adm.getAseguradoraDesc(),false,false,true,40,40)%><%=fb.button("btnAsegura","...",true,false,null,null,"onClick=\"javascript:addAseguradora()\"")%></td>														
								<td>P&oacute;liza</td>
								<td><%=fb.textBox("poliza",adm.getPoliza(),false,false,false,40,30)%></td>														
							</tr>
							<tr class="TextRow01">
							    <td>Observaciones</td>
								<td colspan="3"><%=fb.textarea("observaciones",adm.getObservaciones(),false,false,false,91,5)%></td> 
							</tr>										
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Planes x Habitaci&oacute;n</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<iframe name="itemFrame1" id="itemFrame1" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../residencial/planesresidentes_config.jsp?modeAdm=<%=modeAdm%>&pLastLineNo=<%=pLastLineNo%>&count=<%=count%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod(1)\"")%>
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

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form2",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","2")%>
<%=fb.hidden("modeCust",modeCust)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("errCode","")%>
<%=fb.hidden("errMsg","")%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("admision",adm.getSecuencia())%>
<%=fb.hidden("cLastLineNo",""+cLastLineNo)%>
<%=fb.hidden("keySize",""+iSuple.size())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(20)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Custodio Del Residente</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus10" style="display:none">+</label><label id="minus10">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel20">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
							<tr class="TextRow01">
								<td width="10%">Nombres</td>
								<td width="50%"><%=fb.textBox("primerNombre",cus.getPrimerNombre(),false,false,false,15)%><%=fb.textBox("segundoNombre",cus.getSegundoNombre(),false,false,false,15)%></td>														
								<td width="10%">Secuencia</td>
								<td width="30%"><%=fb.textBox("secuencia",cus.getSecuencia(),false,false,true,15)%></td>																						
							</tr>					
							<tr class="TextRow01">
								<td>Apellidos</td>
								<td colspan="3"><%=fb.textBox("primerApellido",cus.getPrimerApellido(),false,false,false,15)%><%=fb.textBox("segundoApellido",cus.getSegundoApellido(),false,false,false,15)%><%=fb.textBox("apellidoCasada",cus.getApellidoCasada(),false,false,false,15)%></td>																						
							</tr>							
							<tr class="TextRow01">
								<td>C&eacute;d./Pasap.</td>
								<td><%=fb.textBox("identificacion",cus.getIdentificacion(),true,false,false,20)%></td>
								<td>Estado</td>
								<td><%=fb.select("estado","A=Activo,I=Inactivo",cus.getEstado())%></td>
							</tr>
							<tr class="TextRow01">
								<td>Parentesco</td>
								<td><%=fb.textBox("parentesco",cus.getParentesco(),false,false,false,20)%></td>
								<td>Sexo</td>
								<td><%=fb.select("sexo","M=Masculino,F=Femenino",cus.getSexo())%></td>
							</tr>
							<tr class="TextRow01">
								<td>Tel. Casa</td>
								<td><%=fb.textBox("telefonoCasa",cus.getTelefonoCasa(),false,false,false,20)%></td>
								<td>Tel. Oficina</td>
								<td><%=fb.textBox("telefonoOficina",cus.getTelefonoOficina(),false,false,false,20)%></td>
							</tr>
							<tr class="TextRow01">							
								<td>Celular</td>
								<td><%=fb.textBox("celular",cus.getCelular(),false,false,false,20)%></td>
								<td>Fax</td>
								<td><%=fb.textBox("fax",cus.getFax(),false,false,false,20)%></td>
							</tr>
							<tr class="TextRow01">							
								<td>Apartado</td>
								<td><%=fb.textBox("apartado",cus.getApartado(),false,false,false,20)%></td>
								<td>Email</td>
								<td><%=fb.emailBox("email",cus.getEmail(),false,false,false,20)%></td>
							</tr>
							<tr class="TextRow01">							
								<td>Empresa</td>
								<td><%=fb.textBox("empresa",cus.getEmpresa(),false,false,false,20)%></td>
								<td>Ocupaci&oacute;n</td>
								<td><%=fb.textBox("ocupacion",cus.getOcupacion(),false,false,false,20)%></td>														
							</tr>
							<tr class="TextRow01">
							    <td>Direcci&oacute;n</td>
								<td colspan="3"><%=fb.textBox("direccion",cus.getDireccion(),false,false,false,70)%></td> 
							</tr>
							<tr class="TextRow01">
							    <td>Observaciones</td>
								<td colspan="3"><%=fb.textarea("observaciones",cus.getObservaciones(),false,false,false,80,5)%></td> 
							</tr>										
						</table>
					</td>
				</tr>
				<tr>
					<td onClick="javascript:showHide(11)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
							<tr class="TextPanel">
								<td width="95%">&nbsp;Suplentes de Custodio</td>
								<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus11" style="display:none">+</label><label id="minus11">-</label></font>]&nbsp;</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="panel11">
					<td>
						<iframe name="itemFrame2" id="itemFrame2" frameborder="0" align="center" width="100%" height="73" scrolling="no" src="../residencial/suplentescustodio_config.jsp?modeCust=<%=modeCust%>&cLastLineNo=<%=cLastLineNo%>&count=<%=count%>"></iframe>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.button("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod(2)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB2 DIV END HERE-->
</div>

<!-- TAB3 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form3",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","3")%>
<%=fb.hidden("modeAcomp",modeAcomp)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("admision",adm.getSecuencia())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(30)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Acompañantes del Residentes</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus30" style="display:none">+</label><label id="minus30">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel30">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
						<tr class="TextRow01">
							<td width="10%">Nombres</td>
					      	<td width="40%"><%=fb.textBox("nombres",acomp.getColValue("nombres"),false,false,false,35)%></td>
							<td width="10%">No.</td>
					      	<td width="40%"><%=fb.textBox("secuencia",acomp.getColValue("secuencia"),false,false,true,15)%></td>													
						</tr>
						<tr class="TextRow01">
						    <td>Apellidos</td>
					      	<td><%=fb.textBox("apellidos",acomp.getColValue("apellidos"),false,false,false,35)%></td>
							<td>Estado</td>
					      	<td><%=fb.select("estado","A=Activo,I=Inactivo",acomp.getColValue("estado"))%></td>							
						</tr>
						<tr class="TextRow01">
						    <td>Céd./Pasap.</td>
					      	<td><%=fb.textBox("identificacion",acomp.getColValue("identificacion"),false,false,false,35)%></td>
						    <td>Tel. Casa</td>
					      	<td><%=fb.textBox("telCasa",acomp.getColValue("telefonoCasa"),false,false,false,35)%></td>																																																	
						</tr>
						<tr class="TextRow01">
						    <td>Por Urgencia</td>
					      	<td><%=fb.textBox("perUrgencia",acomp.getColValue("perUrgencia"),false,false,false,35)%></td>							
						    <td>Tel. Urgencia</td>
					      	<td><%=fb.textBox("telUrgencia",acomp.getColValue("telUrgencia"),false,false,false,35)%></td>																																																	
						</tr>
						<tr class="TextRow01">
						    <td>Educaci&oacute;n</td>
					      	<td><%=fb.textBox("educacion",acomp.getColValue("educacion"),false,false,false,35)%></td>
						    <td>Celular</td>
					      	<td><%=fb.textBox("celular",acomp.getColValue("telefonoCelular"),false,false,false,35)%></td>																																																	
						</tr>
						<tr class="TextRow01">
						    <td>Direcci&oacute;n</td>
					      	<td colspan="3"><%=fb.textBox("direccion",acomp.getColValue("direccion"),false,false,false,120)%></td>		   						</tr>	
							<tr class="TextRow01">
						    <td>Observaciones</td>
					      	<td colspan="3"><%=fb.textarea("observaciones",acomp.getColValue("observaciones"),false,false,false,90,4)%></td>		   						
						</tr>			
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB3 DIV END HERE-->
</div>

<!-- TAB4 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form4",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","4")%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("mLastLineNo",""+mLastLineNo)%>
<%=fb.hidden("medSize",""+iMedi.size())%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("admision",adm.getSecuencia())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(40)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Doctores</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus40" style="display:none">+</label><label id="minus40">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel40">				
					<td>
						<table width="100%" cellpadding="1" cellspacing="1">
						<tr class="TextHeader" align="center">
							<td width="35%">Nombre</td>
							<td width="10%">id</td>
							<td width="35%">Especialidad</td>
							<td width="15%">Tel&eacute;fono</td>
							<td width="5%"><%=fb.submit("addMedico","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
						</tr>
						<%
						mList = CmnMgr.reverseRecords(iMedi);				
						for (int i=1; i<=iMedi.size(); i++)
						{
						  key = mList.get(i - 1).toString();									  
						  CommonDataObject cdo2 = (CommonDataObject) iMedi.get(key);
						  String fechaCreacion = "fechaCreacion"+i;
						%>
						<%=fb.hidden("key"+i,cdo2.getColValue("key"))%>
						<%=fb.hidden("medicEspec"+i,cdo2.getColValue("medicEspec"))%>
						<%=fb.hidden("codigo"+i,cdo2.getColValue("med_ref_id"))%>
						<%=fb.hidden("nombre"+i,cdo2.getColValue("med_ref_nombre"))%>
						<%=fb.hidden("especialidadId"+i,cdo2.getColValue("med_espec_ini"))%>
						<%=fb.hidden("descripcion"+i,cdo2.getColValue("med_especialid"))%>
						<%=fb.hidden("telefono"+i,cdo2.getColValue("med_ref_tel"))%>						
						<%=fb.hidden("remove"+i,"")%>
						<tr class="TextRow01">
						    <td><%=cdo2.getColValue("med_ref_nombre")%></td>
							<td><%=cdo2.getColValue("med_ref_id")%></td>							
							<td><%=cdo2.getColValue("med_especialid")%></td>
							<td><%=cdo2.getColValue("med_ref_tel")%></td>
							<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
						</tr>
						<%
						}
						%>
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB4 DIV END HERE-->
</div>

<!-- TAB5 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form5",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","5")%>
<%=fb.hidden("modeRel",modeRel)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("admision",adm.getSecuencia())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(50)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Relevo de Responsabilidad</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus50" style="display:none">+</label><label id="minus50">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel50">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">									
						<tr class="TextRow01">
							<td width="10%">Yo</td>
					      	<td width="44%"><%=fb.textBox("responsable",rel.getColValue("responsable"),false,false,false,51)%></td>
							<td width="10%">Custodio de</td>
					      	<td width="36%"><%=fb.textBox("residente",rel.getColValue("residente"),false,false,true,40)%></td>													
						</tr>
						<tr class="TextRow01">
						<td colspan="2"><%=fb.checkbox("nmt","S",(rel.getColValue("nmt") != null && rel.getColValue("nmt").equalsIgnoreCase("S")),false)%>&nbsp;No administrar medicamentos y/o tratamientos ordenados por su m&eacute;dico</td>	
						    <td colspan="2"><%=fb.checkbox("nrf","S",(rel.getColValue("nrf") != null && rel.getColValue("nrf").equalsIgnoreCase("S")),false)%>&nbsp;No restricciones f&iacute;sica</td>									
						</tr>
						<tr class="TextRow01">
						    <td colspan="2"><%=fb.checkbox("nth","S",(rel.getColValue("nth") != null && rel.getColValue("nth").equalsIgnoreCase("S")),false)%>&nbsp;No transferencia hospitalarias</td>
							<td colspan="2"><%=fb.checkbox("ngp","S",(rel.getColValue("ngp") != null && rel.getColValue("ngp").equalsIgnoreCase("S")),false)%>&nbsp;No giras o paseos en la ciudad de Panam&aacute;</td>				
						</tr>
						<tr class="TextRow01">
						    <td colspan="2"><%=fb.checkbox("nah","S",(rel.getColValue("nah") != null && rel.getColValue("nah").equalsIgnoreCase("S")),false)%>&nbsp;No realizar actos hero&iacute;cos</td>	
							<td colspan="2"><%=fb.checkbox("ndm","S",(rel.getColValue("ndm") != null && rel.getColValue("ndm").equalsIgnoreCase("S")),false)%>&nbsp;No subjetarse a la dieta indicada por su m&eacute;dico</td>			
						</tr>						
						<tr class="TextRow01">
						    <td>Observaciones</td>
							<td><%=fb.textBox("observacion",rel.getColValue("observacion"),false,false,false,51)%></td>			
							<td>Fecha</td>
							<td><jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1" />
								<jsp:param name="clearOption" value="true" />
								<jsp:param name="nameOfTBox1" value="fecha" />
								<jsp:param name="valueOfTBox1" value="<%=(modeRel.equals("edit")?rel.getColValue("fecha"):" ")%>" />
								</jsp:include></td>	
						</tr>
						<tr class="TextRow01">
						    <td>Testigo</td>
					      	<td><%=fb.textBox("testigo",rel.getColValue("testigo"),false,false,false,51)%></td>
						    <td>Custodio/Resid./Familiar</td>
					      	<td><%=fb.textBox("cusResFam",rel.getColValue("cusResFam"),false,false,false,40)%></td>   																																																	
						</tr>								
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB5 DIV END HERE-->
</div>

<!-- TAB6 DIV START HERE-->
<div class="dhtmlgoodies_aTab">

				<table align="center" width="100%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->

<%fb = new FormBean("form6",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","6")%>
<%=fb.hidden("modeServ",modeServ)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("prov",prov)%>
<%=fb.hidden("asiento",asiento)%>
<%=fb.hidden("tomo",tomo)%>
<%=fb.hidden("sigla",sigla)%>
<%=fb.hidden("admision",adm.getSecuencia())%>

				<tr class="TextRow02">
					<td>&nbsp;</td>
				</tr>

				<tr>
					<td onClick="javascript:showHide(60)" style="text-decoration:none; cursor:pointer">
						<table width="100%" cellpadding="1" cellspacing="0">
						<tr class="TextPanel">
							<td width="95%">&nbsp;Relevo de Responsabilidad</td>
							<td width="5%" align="right">[<font face="Courier New, Courier, mono"><label id="plus60" style="display:none">+</label><label id="minus60">-</label></font>]&nbsp;</td>
						</tr>
						</table>
					</td>
				</tr>
				<tr id="panel60">
					<td>	
						<table width="100%" cellpadding="1" cellspacing="1">															
						<tr class="TextRow01">
						    <td width="50%"><%=fb.checkbox("ausf","S",(serv.getColValue("ausf") != null && serv.getColValue("ausf").equalsIgnoreCase("S")),false)%>&nbsp;Atenci&oacute;n de Urgencias Cl&iacute;nica San Fernando</td>	
						    <td width="50%"><%=fb.checkbox("exal","S",(serv.getColValue("exal") != null && serv.getColValue("exal").equalsIgnoreCase("S")),false)%>&nbsp;Ex&aacute;menes de Laboratorios</td>									
						</tr>
						<tr class="TextRow01">
						    <td><%=fb.checkbox("ames","S",(serv.getColValue("ames") != null && serv.getColValue("ames").equalsIgnoreCase("S")),false)%>&nbsp;Atenci&oacute;n de M&eacute;dicos Especialistas C.H.S.F.</td>
							<td><%=fb.checkbox("radi","S",(serv.getColValue("radi") != null && serv.getColValue("radi").equalsIgnoreCase("S")),false)%>&nbsp;Radiolog&iacute;a</td>				
						</tr>
						<tr class="TextRow01">
						    <td><%=fb.checkbox("fisi","S",(serv.getColValue("fisi") != null && serv.getColValue("fisi").equalsIgnoreCase("S")),false)%>&nbsp;Fisioterapia</td>	
							<td><%=fb.checkbox("eort","S",(serv.getColValue("eort") != null && serv.getColValue("eort").equalsIgnoreCase("S")),false)%>&nbsp;Equipo Ortop&eacute;dico</td>			
						</tr>
						<tr class="TextRow01">
						    <td><%=fb.checkbox("medi","S",(serv.getColValue("medi") != null && serv.getColValue("medi").equalsIgnoreCase("S")),false)%>&nbsp;Medicamentos</td>	
							<td><%=fb.checkbox("alen","S",(serv.getColValue("alen") != null && serv.getColValue("alen").equalsIgnoreCase("S")),false)%>&nbsp;Alimentaci&oacute;n Enteral(F&oacute;rmula L&aacute;ctea)</td>			
						</tr>
						<tr class="TextRow01">
						    <td><%=fb.checkbox("refr","S",(serv.getColValue("refr") != null && serv.getColValue("refr").equalsIgnoreCase("S")),false)%>&nbsp;Refrigerios</td>	
							<td><%=fb.checkbox("sepe","S",(serv.getColValue("sepe") != null && serv.getColValue("sepe").equalsIgnoreCase("S")),false)%>&nbsp;Servicios de Peluquer&iacute;a</td>			
						</tr>
						<tr class="TextRow01">
						    <td><%=fb.checkbox("sepo","S",(serv.getColValue("sepo") != null && serv.getColValue("sepo").equalsIgnoreCase("S")),false)%>&nbsp;Servicios de Podiatr&iacute;a</td>	
							<td><%=fb.checkbox("arec","S",(serv.getColValue("arec") != null && serv.getColValue("arec").equalsIgnoreCase("S")),false)%>&nbsp;Actividades Recreativas Extra Institucional</td>			
						</tr>						
						<tr class="TextRow01">
						    <td width="12%">Observaciones</td>
							<td width="88%"><%=fb.textarea("observaciones",serv.getColValue("observaciones"),false,false,false,60,4)%></td>										
						</tr>															
						</table>
					</td>
				</tr>
				<tr class="TextRow02">
					<td align="right">
						Opciones de Guardar: 
						<%=fb.radio("saveOption","N")%>Crear Otro 
						<%=fb.radio("saveOption","O")%>Mantener Abierto 
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar 
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
<%=fb.formEnd(true)%>

<!-- ================================   F O R M   E N D   H E R E   ================================ -->

				</table>

<!-- TAB6 DIV END HERE-->
</div>

<!-- MAIN DIV END HERE -->
</div>
<script type="text/javascript">
<%
if (mode.equalsIgnoreCase("add"))
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Principal'),0,'100%','');
<%
}
else if (mode.equalsIgnoreCase("edit") && count > 0)
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Principal','Ingreso','Custodio','Acompañante','Doctores','Rel. Responsable','Autoriz. Servicio'),<%=tab%>,'100%','');
<%
}
else
{
%>
initTabs('dhtmlgoodies_tabView1',Array('Principal','Ingreso'),<%=tab%>,'100%',''); 
<%
}
%>
</script>

			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<jsp:include page="../common/footer.jsp" flush="true"></jsp:include>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");
	String errCode = "";
    String errMsg = "";
    String code   = "";
	prov = request.getParameter("prov");
	asiento = request.getParameter("asiento");
	tomo = request.getParameter("tomo");
	sigla = request.getParameter("sigla");
	
	if (tab.equals("0")) //RESIDENTE
	{
		cdo = new CommonDataObject();

  	    cdo.setTableName("tbl_res_residente");		
		
		cdo.addColValue("primer_apellido",request.getParameter("primerApellido"));
		cdo.addColValue("apellido_casada",request.getParameter("apellidoCasada"));
		cdo.addColValue("segundo_apellido",request.getParameter("segundoApellido"));
		cdo.addColValue("sexo",request.getParameter("sexo"));
		cdo.addColValue("fecha_nac",request.getParameter("fechaNac"));
		cdo.addColValue("estado_civil",request.getParameter("estadoCivil"));
		cdo.addColValue("direccion",request.getParameter("direccion"));
		cdo.addColValue("telefono",request.getParameter("telefono"));
		//cdo.addColValue("estado",request.getParameter("estado"));
		cdo.addColValue("fallecido",request.getParameter("fallecido"));
		cdo.addColValue("seguro_social",request.getParameter("seguroSocial"));
		cdo.addColValue("religion",request.getParameter("religion"));
		cdo.addColValue("nacionalidad",request.getParameter("nacionalidad"));
		cdo.addColValue("observaciones",request.getParameter("observaciones"));
		cdo.addColValue("edad",request.getParameter("edad"));
		cdo.addColValue("primer_nombre",request.getParameter("primerNombre"));
		cdo.addColValue("segundo_nombre",request.getParameter("segundoNombre"));
		cdo.addColValue("lugar_nac",request.getParameter("lugarNac"));
		cdo.addColValue("ingreso_fam",request.getParameter("ingresoFam"));
		cdo.addColValue("saldo",request.getParameter("saldo"));
		cdo.addColValue("saldo_empieza",request.getParameter("saldoEmpieza"));
		
		
	    if (mode.equalsIgnoreCase("add"))
	    {   
		    cdo.setAutoIncWhereClause("compania="+(String) session.getAttribute("_companyId"));
		    cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo.addColValue("provincia",request.getParameter("prov"));
			cdo.addColValue("sigla",request.getParameter("sigla"));
			cdo.addColValue("tomo",request.getParameter("tomo"));
			cdo.addColValue("asiento",request.getParameter("asiento"));	
			cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));

			SQLMgr.insert(cdo);
		}
		else if (mode.equalsIgnoreCase("edit"))
		{
		    cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
			cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
			cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+request.getParameter("sigla")+"' and tomo="+request.getParameter("tomo")+" and asiento="+request.getParameter("asiento"));

			SQLMgr.update(cdo);
		}
		errCode = SQLMgr.getErrCode();
		errMsg  = SQLMgr.getErrMsg();
	} //END TAB 0
	else if (tab.equals("1"))
	{
	   errCode = request.getParameter("errCode");
       errMsg = request.getParameter("errMsg");
	} //END TAB 1
   	else if (tab.equals("2"))	
    {
	   errCode = request.getParameter("errCode");
	   errMsg = request.getParameter("errMsg");
	} //END TAB 2
	else if (tab.equals("3"))
	{
	   modeAcomp = request.getParameter("modeAcomp");
	   
	   cdo = new CommonDataObject();

  	   cdo.setTableName("tbl_res_acompanante");		
		
	   cdo.addColValue("identificacion",request.getParameter("identificacion"));
	   if (request.getParameter("nombres") != null && !request.getParameter("nombres").trim().equals(""))
	   cdo.addColValue("nombres",request.getParameter("nombres"));
	   if (request.getParameter("apellidos") != null && !request.getParameter("apellidos").trim().equals(""))
	   cdo.addColValue("apellidos",request.getParameter("apellidos"));
	   if (request.getParameter("telUrgencia") != null && !request.getParameter("telUrgencia").trim().equals(""))
	   cdo.addColValue("tel_urgencia",request.getParameter("telUrgencia"));
	   if (request.getParameter("telCasa") != null && !request.getParameter("telCasa").trim().equals(""))
	   cdo.addColValue("telefono_casa",request.getParameter("telCasa"));
	   if (request.getParameter("celular") != null && !request.getParameter("celular").trim().equals(""))
	   cdo.addColValue("telefono_celular",request.getParameter("celular"));
	   cdo.addColValue("estado",request.getParameter("estado"));
	   if (request.getParameter("perUrgencia") != null && !request.getParameter("perUrgencia").trim().equals(""))
	   cdo.addColValue("per_urgencia",request.getParameter("perUrgencia"));
	   if (request.getParameter("educacion") != null && !request.getParameter("educacion").trim().equals(""))
	   cdo.addColValue("educacion",request.getParameter("educacion"));
	   if (request.getParameter("direccion") != null && !request.getParameter("direccion").trim().equals(""))
	   cdo.addColValue("direccion",request.getParameter("direccion"));
	   if (request.getParameter("observaciones") != null && !request.getParameter("observaciones").trim().equals(""))
	   cdo.addColValue("observaciones",request.getParameter("observaciones"));		
		
	   if (modeAcomp.equalsIgnoreCase("add"))
	   {  
		  cdo.addColValue("cia",(String) session.getAttribute("_companyId"));
		  cdo.addColValue("provi_r",request.getParameter("prov"));
		  cdo.addColValue("sigla_r",request.getParameter("sigla"));
		  cdo.addColValue("tomo_r",request.getParameter("tomo"));
		  cdo.addColValue("asien_r",request.getParameter("asiento"));	
		  cdo.addColValue("admision",request.getParameter("admision"));	
		  cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		  cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		  
		  cdo.setAutoIncCol("secuencia");
		  cdo.addPkColValue("secuencia","");
		  
		  SQLMgr.insert(cdo);
		  
		  code = SQLMgr.getPkColValue("secuencia"); 
	   }
	   else if (modeAcomp.equalsIgnoreCase("edit"))
	   {
		  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		  cdo.setWhereClause("cia="+(String) session.getAttribute("_companyId")+" and provi_r="+request.getParameter("prov")+" and sigla_r='"+request.getParameter("sigla")+"' and tomo_r="+request.getParameter("tomo")+" and asien_r="+request.getParameter("asiento")+" and admision = "+request.getParameter("admision"));

		  SQLMgr.update(cdo);
	   }
	   errCode = SQLMgr.getErrCode();
	   errMsg  = SQLMgr.getErrMsg();
	}    //END TAB 3
	else if (tab.equals("4")) 
	{
		int size = 0;
		if (request.getParameter("medSize") != null) size = Integer.parseInt(request.getParameter("medSize"));
		String itemRemoved = "";

		mList.clear();
		for (int i=1; i<=size; i++)
		{
			CommonDataObject cdo3 = new CommonDataObject();

			cdo3.setTableName("tbl_res_med_residente");  
			cdo3.setWhereClause("asiento="+request.getParameter("asiento")+" and tomo="+request.getParameter("tomo")+" and sigla='"+request.getParameter("sigla")+"' and provincia="+request.getParameter("prov")+" and admision="+request.getParameter("admision")+" and compania="+(String) session.getAttribute("_companyId"));
			cdo3.addColValue("medicEspec",request.getParameter("medicEspec"+i));
			cdo3.addColValue("med_ref_id",request.getParameter("codigo"+i));
			cdo3.addColValue("asiento",request.getParameter("asiento"));
			cdo3.addColValue("tomo",request.getParameter("tomo"));
			cdo3.addColValue("sigla",request.getParameter("sigla"));			
			cdo3.addColValue("provincia",request.getParameter("prov"));
			cdo3.addColValue("admision",request.getParameter("admision"));
			cdo3.addColValue("compania",(String) session.getAttribute("_companyId"));
			cdo3.addColValue("med_ref_nombre",request.getParameter("nombre"+i));
			cdo3.addColValue("med_especialid",request.getParameter("descripcion"+i));
			cdo3.addColValue("med_espec_ini",request.getParameter("especialidadId"+i));
			cdo3.addColValue("med_ref_tel",request.getParameter("telefono"+i));

			cdo3.addColValue("key",request.getParameter("key"+i));

			if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
				itemRemoved = cdo3.getColValue("key");  
			else 
			{
				try
				{
					iMedi.put(cdo3.getColValue("key"),cdo3); 
					mList.add(cdo3); 
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}
			}	
		}

		if (!itemRemoved.equals(""))
		{
		   vMedi.remove(((CommonDataObject) iMedi.get(itemRemoved)).getColValue("medicEspec"));
    	   iMedi.remove(itemRemoved);

	       response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&mode="+mode+"&prov="+prov+"&asiento="+asiento+"&tomo="+tomo+"&sigla="+sigla+"&mLastLineNo="+mLastLineNo);
    	return;
		}

		if (baction != null && baction.equals("+"))
		{
	       response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&tab=4&type=1&mode="+mode+"&prov="+prov+"&asiento="+asiento+"&tomo="+tomo+"&sigla="+sigla+"&mLastLineNo="+mLastLineNo);
    	return;
		}

		if (mList.size() == 0)
		{
			CommonDataObject cdo4 = new CommonDataObject();

			cdo4.setTableName("tbl_res_med_residente");  
			cdo4.setWhereClause("asiento="+request.getParameter("asiento")+" and tomo="+request.getParameter("tomo")+" and sigla='"+request.getParameter("sigla")+"' and provincia="+request.getParameter("prov")+" and admision="+request.getParameter("admision")+" and compania="+(String) session.getAttribute("_companyId"));

			mList.add(cdo4); 
		}

		SQLMgr.insertList(mList);
		errCode = SQLMgr.getErrCode();
	    errMsg  = SQLMgr.getErrMsg(); 
	}	 //END TAB 4	
	else if (tab.equals("5"))
	{
	   modeRel = request.getParameter("modeRel");
	   cdo = new CommonDataObject();

  	   cdo.setTableName("tbl_res_relevo");		
		
	   if (request.getParameter("observacion") != null && !request.getParameter("observacion").trim().equals(""))
	   cdo.addColValue("observacion",request.getParameter("observacion"));
	   if (request.getParameter("responsable") != null && !request.getParameter("responsable").trim().equals(""))
	   cdo.addColValue("responsable",request.getParameter("responsable"));
	   cdo.addColValue("nrf",(request.getParameter("nrf")==null)?"N":"S");
	   cdo.addColValue("nth",(request.getParameter("nth")==null)?"N":"S");
	   cdo.addColValue("nah",(request.getParameter("nah")==null)?"N":"S");
	   cdo.addColValue("ndm",(request.getParameter("ndm")==null)?"N":"S");
	   cdo.addColValue("nmt",(request.getParameter("nmt")==null)?"N":"S");
	   cdo.addColValue("ngp",(request.getParameter("ngp")==null)?"N":"S");
	   if (request.getParameter("cusResFam") != null && !request.getParameter("cusResFam").trim().equals(""))
	   cdo.addColValue("cus_res_fam",request.getParameter("cusResFam"));	
	   if (request.getParameter("fecha") != null && !request.getParameter("fecha").trim().equals(""))
	   cdo.addColValue("fecha",request.getParameter("fecha"));
	   if (request.getParameter("testigo") != null && !request.getParameter("testigo").trim().equals(""))
	   cdo.addColValue("testigo",request.getParameter("testigo"));	
		
	   if (modeRel.equalsIgnoreCase("add"))
	   {   
		  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		  cdo.addColValue("provincia",request.getParameter("prov"));
		  cdo.addColValue("sigla",request.getParameter("sigla"));
		  cdo.addColValue("tomo",request.getParameter("tomo"));
		  cdo.addColValue("asiento",request.getParameter("asiento"));	
		  cdo.addColValue("admision",request.getParameter("admision"));	
		  cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		  cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
 
		  SQLMgr.insert(cdo);
	   }
	   else if (modeRel.equalsIgnoreCase("edit"))
	   {
		  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		  cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+request.getParameter("sigla")+"' and tomo="+request.getParameter("tomo")+" and asiento="+request.getParameter("asiento")+" and admision="+request.getParameter("admision"));

		  SQLMgr.update(cdo);
	   }
	   errCode = SQLMgr.getErrCode();
	   errMsg  = SQLMgr.getErrMsg();   
   } //END TAB 5
    else if (tab.equals("6"))
    {
       modeServ = request.getParameter("modeServ");
	   
	   cdo = new CommonDataObject();

  	   cdo.setTableName("tbl_res_servicios");		
			  
	   cdo.addColValue("ausf",(request.getParameter("ausf")==null)?"N":"S");
	   cdo.addColValue("ames",(request.getParameter("ames")==null)?"N":"S");
	   cdo.addColValue("exal",(request.getParameter("exal")==null)?"N":"S");
	   cdo.addColValue("radi",(request.getParameter("radi")==null)?"N":"S");
	   cdo.addColValue("fisi",(request.getParameter("fisi")==null)?"N":"S");
	   cdo.addColValue("aort",(request.getParameter("aort")==null)?"N":"S");
	   cdo.addColValue("medi",(request.getParameter("medi")==null)?"N":"S");
	   cdo.addColValue("alen",(request.getParameter("alen")==null)?"N":"S");
	   cdo.addColValue("refr",(request.getParameter("refr")==null)?"N":"S");
	   cdo.addColValue("sepe",(request.getParameter("sepe")==null)?"N":"S");
	   cdo.addColValue("sepo",(request.getParameter("sepo")==null)?"N":"S");
	   cdo.addColValue("arec",(request.getParameter("arec")==null)?"N":"S");
	   if (request.getParameter("observaciones") != null && !request.getParameter("observaciones").trim().equals(""))
	   cdo.addColValue("observaciones",request.getParameter("observaciones"));	
		
	   if (modeServ.equalsIgnoreCase("add"))
	   {   
		  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
		  cdo.addColValue("provincia",request.getParameter("prov"));
		  cdo.addColValue("sigla",request.getParameter("sigla"));
		  cdo.addColValue("tomo",request.getParameter("tomo"));
		  cdo.addColValue("asiento",request.getParameter("asiento"));	
		  cdo.addColValue("admision",request.getParameter("admision"));	
		  cdo.addColValue("usuario_creacion",(String) session.getAttribute("_userName"));
		  cdo.addColValue("fecha_creacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
 
		  SQLMgr.insert(cdo);
	   }
	   else if (modeServ.equalsIgnoreCase("edit"))
	   {
		  cdo.addColValue("usuario_modificacion",(String) session.getAttribute("_userName"));
		  cdo.addColValue("fecha_modificacion",CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		  cdo.setWhereClause("compania="+(String) session.getAttribute("_companyId")+" and provincia="+request.getParameter("prov")+" and sigla='"+request.getParameter("sigla")+"' and tomo="+request.getParameter("tomo")+" and asiento="+request.getParameter("asiento")+" and admision="+request.getParameter("admision"));

		  SQLMgr.update(cdo);
	   }
	   errCode = SQLMgr.getErrCode();
	   errMsg  = SQLMgr.getErrMsg();   
    } //END TAB 6
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
<%
if (errCode.equals("1"))
{
%>
	alert('<%=errMsg%>');
<%
	if (tab.equals("0"))
	{
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/residencial/residente_list.jsp"))
		{
%>
	       window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/residencial/residente_list.jsp")%>';
<%
		}
		else
		{
%>
           window.opener.location = '<%=request.getContextPath()%>/residencial/residente_list.jsp';
<%
		}
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
} else throw new Exception(errMsg);
%>
}

function addMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&tab=<%=tab%>&prov=<%=prov%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>';
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>