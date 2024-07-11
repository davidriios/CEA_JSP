<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.residencial.DetallePlan"%>
<%@ page import="issi.residencial.ResAdmision"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iHab" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vHab" scope="session" class="java.util.Vector" />
<jsp:useBean id="AdmMgr" scope="page" class="issi.residencial.ResAdmisionMgr" />
<%
/**
==================================================================================
==================================================================================
**/
SecMgr.setConnection(ConMgr);
//if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (SecMgr.checkAccess(session.getId(),"0")) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
AdmMgr.setConnection(ConMgr);

CommonDataObject obj = new CommonDataObject();
ArrayList al = new ArrayList();
String key = "";
String sql = "";
String tab = request.getParameter("tab");
String modeAdm = request.getParameter("modeAdm");
String change = request.getParameter("change");
int pLastLineNo = 0;

if (tab == null) tab = "0";
if (request.getParameter("pLastLineNo") != null) pLastLineNo = Integer.parseInt(request.getParameter("pLastLineNo"));

if (request.getMethod().equalsIgnoreCase("GET"))
{
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<%@ include file="../common/tab.jsp" %>
<script language="javascript">
document.title = 'Tabs Admisión - '+document.title;

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
	newHeight();
<% 
	if (request.getParameter("type")!= null && request.getParameter("type").equals("1"))
	{
%> 
       addPlanHabit();
<%
    }
%>	
}
function addPlanHabit()
{
   abrir_ventana1('../common/check_planes_x_habitacion.jsp?modeAdm=<%=modeAdm%>&fp=tipoHabit&pLastLineNo=<%=pLastLineNo%>');
}
function doSubmit()
{ 
   document.form1.admision.value = parent.document.form1.secuencia.value;
   document.form1.asiento.value = parent.document.form1.asiento.value;
   document.form1.tomo.value = parent.document.form1.tomo.value;
   document.form1.sigla.value = parent.document.form1.sigla.value;
   document.form1.provincia.value = parent.document.form1.prov.value;
   document.form1.fechaIngreso.value = parent.document.form1.fechaIngreso.value;
   document.form1.fechaEgreso.value = parent.document.form1.fechaEgreso.value;
   document.form1.alergias.value = parent.document.form1.alergias.value;
   document.form1.diagnostico.value = parent.document.form1.diagnostico.value;
   document.form1.medicoRefId.value = parent.document.form1.medicoRefId.value;
   document.form1.medicoRefNombre.value = parent.document.form1.medicoRefNombre.value;
   document.form1.medicoRefTel.value = parent.document.form1.medicoRefTel.value;
   document.form1.aseguradora.value = parent.document.form1.aseguradora.value;
   document.form1.poliza.value = parent.document.form1.poliza.value;
   document.form1.observaciones.value = parent.document.form1.observaciones.value;  
   
   document.form1.submit(); 

} 
function addHab(i)
{
   abrir_ventana1('../common/search_cama.jsp?fp=planHabit&index='+i);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<table width="100%" cellpadding="1" cellspacing="1">
<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
<%=fb.formStart(true)%>
<%=fb.hidden("tab","1")%>
<%=fb.hidden("modeAdm",modeAdm)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("iHabSize",""+iHab.size())%>
<%=fb.hidden("pLastLineNo",""+pLastLineNo)%>
<%=fb.hidden("admision","")%>
<%=fb.hidden("asiento","")%>
<%=fb.hidden("tomo","")%>
<%=fb.hidden("sigla","")%>
<%=fb.hidden("provincia","")%>
<%=fb.hidden("fechaIngreso","")%>
<%=fb.hidden("fechaEgreso","")%>
<%=fb.hidden("alergias","")%>
<%=fb.hidden("diagnostico","")%>
<%=fb.hidden("medicoRefId","")%>
<%=fb.hidden("medicoRefNombre","")%>
<%=fb.hidden("medicoRefTel","")%>
<%=fb.hidden("aseguradora","")%>
<%=fb.hidden("poliza","")%>
<%=fb.hidden("observaciones","")%>

<tr class="TextHeader" align="center">
	<td width="35%">Planes</td>
	<td width="30%">Tipo Habitaci&oacute;n</td>
	<td width="20%">Habitaci&oacute;n</td>
	<td width="10%">Descuentos</td>
	<td width="5%"><%=fb.submit("addPlan","+",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"","Agregar")%></td>
</tr>
<%
al = CmnMgr.reverseRecords(iHab);				
for (int i=1; i<=iHab.size(); i++)
{
	key = al.get(i - 1).toString();									  
	DetallePlan pl = (DetallePlan) iHab.get(key);
%>
<%=fb.hidden("secuencia"+i,pl.getSecuencia())%>
<%=fb.hidden("key"+i,pl.getKey())%>
<%=fb.hidden("planes"+i,pl.getPlanes())%>
<%=fb.hidden("planesDesc"+i,pl.getPlanesDesc())%>
<%=fb.hidden("tipoHab"+i,pl.getTipoHab())%>
<%=fb.hidden("tipoHabDesc"+i,pl.getTipoHabDesc())%>
<%=fb.hidden("planHabit"+i,pl.getPlanHabit())%>
<%=fb.hidden("remove"+i,"")%>
<tr class="TextRow01">
	<td><%=pl.getPlanes()%> - <%=pl.getPlanesDesc()%></td>
	<td><%=pl.getTipoHab()%> - <%=pl.getTipoHabDesc()%></td>
	<td><%=fb.textBox("habitacion"+i,pl.getHabitacion(),false,false,false,5,10)%>/<%=fb.textBox("cama"+i,pl.getCama(),false,false,false,5,10)%><%=fb.button("btnHab","...",true,false,null,null,"onClick=\"javascript:addHab("+i+")\"")%></td>
	<td><%=fb.decBox("descuento"+i,pl.getDescuento(),false,false,false,10,8.2)%></td>
	<td align="center"><%=fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\"","Eliminar")%></td>
</tr>
<%
}
%>
<%=fb.formEnd(true)%>
</table>
</body>
</html>
<%
}//GET
else
{
	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	int size = 0;
	if (request.getParameter("iHabSize") != null) size = Integer.parseInt(request.getParameter("iHabSize"));
	String itemRemoved = "";
	String code = "";

	al.clear();

	for (int i=1; i<=size; i++)
	{
		DetallePlan pl = new DetallePlan();
        
		pl.setSecuencia(request.getParameter("secuencia"+i)); 
		pl.setKey(request.getParameter("key"+i));
		pl.setPlanHabit(request.getParameter("planHabit"+i));	
				  
		if (request.getParameter("planes"+i) != null && !request.getParameter("planes"+i).trim().equals(""))
		{
			pl.setPlanes(request.getParameter("planes"+i));
		}
		if (request.getParameter("planesDesc"+i) != null && !request.getParameter("planesDesc"+i).trim().equals(""))
		{
			pl.setPlanesDesc(request.getParameter("planesDesc"+i));
		}		
		if (request.getParameter("tipoHab"+i) != null && !request.getParameter("tipoHab"+i).trim().equals(""))
		{
			pl.setTipoHab(request.getParameter("tipoHab"+i));
		}
		if (request.getParameter("tipoHabDesc"+i) != null && !request.getParameter("tipoHabDesc"+i).trim().equals(""))
		{
			pl.setTipoHabDesc(request.getParameter("tipoHabDesc"+i));
		}
		if (request.getParameter("habitacion"+i) != null && !request.getParameter("habitacion"+i).trim().equals(""))
		{
			pl.setHabitacion(request.getParameter("habitacion"+i));
		}
		if (request.getParameter("cama"+i) != null && !request.getParameter("cama"+i).trim().equals(""))
		{
			pl.setCama(request.getParameter("cama"+i));
		}
		if (request.getParameter("descuento"+i) != null && !request.getParameter("descuento"+i).trim().equals(""))
		{
			pl.setDescuento(request.getParameter("descuento"+i));
		}		
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")) 
			itemRemoved = pl.getKey();  
		else 
		{
			try
			{
				iHab.put(pl.getKey(),pl);
				al.add(pl); 
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}	
    }
	
		if (!itemRemoved.equals(""))
		{
		  vHab.remove(((DetallePlan) iHab.get(itemRemoved)).getPlanHabit());
    	  iHab.remove(itemRemoved);

	      response.sendRedirect(request.getContextPath()+request.getServletPath()+"?modeAdm="+modeAdm+"&pLastLineNo="+pLastLineNo); 
    	return;
		}

		if (baction != null && baction.equals("+"))
		{ 
	      response.sendRedirect(request.getContextPath()+request.getServletPath()+"?type=1&modeAdm="+modeAdm+"&pLastLineNo="+pLastLineNo);
    	return;
		}

		ResAdmision adm = new ResAdmision(); 

		adm.setSecuencia(request.getParameter("admision"));
		adm.setAsiento(request.getParameter("asiento"));
		adm.setTomo(request.getParameter("tomo"));
		adm.setSigla(request.getParameter("sigla"));
		adm.setProvincia(request.getParameter("provincia"));
		adm.setCompania((String) session.getAttribute("_companyId"));
		if (request.getParameter("fechaIngreso")!= null && !request.getParameter("fechaIngreso").equals(""))
		adm.setFechaIngreso(request.getParameter("fechaIngreso"));
		if (request.getParameter("fechaEgreso")!= null && !request.getParameter("fechaEgreso").equals(""))
		adm.setFechaEgreso(request.getParameter("fechaEgreso"));
		if (request.getParameter("alergias")!= null && !request.getParameter("alergias").trim().equals(""))
		adm.setAlergias(request.getParameter("alergias"));
		if (request.getParameter("diagnostico")!= null && !request.getParameter("diagnostico").trim().equals(""))
		adm.setDiagnostico(request.getParameter("diagnostico"));
		if (request.getParameter("medicoRefId")!= null && !request.getParameter("medicoRefId").trim().equals(""))
		adm.setMedicoRefId(request.getParameter("medicoRefId"));
		if (request.getParameter("medicoRefNombre")!= null && !request.getParameter("medicoRefNombre").trim().equals(""))
		adm.setMedicoRefNombre(request.getParameter("medicoRefNombre"));
		if (request.getParameter("medicoRefTel")!= null && !request.getParameter("medicoRefTel").trim().equals(""))
		adm.setMedicoRefTel(request.getParameter("medicoRefTel"));
		if (request.getParameter("aseguradora")!= null && !request.getParameter("aseguradora").trim().equals(""))
		adm.setAseguradora(request.getParameter("aseguradora"));
		if (request.getParameter("poliza")!= null && !request.getParameter("poliza").trim().equals(""))
		adm.setPoliza(request.getParameter("poliza"));
		if (request.getParameter("observaciones")!= null && !request.getParameter("observaciones").trim().equals(""))
		adm.setObservaciones(request.getParameter("observaciones"));
				
		adm.setDetalle(al);

		if (modeAdm.equalsIgnoreCase("add"))
		{  	 
		   adm.setUsuarioCreacion(UserDet.getUserEmpId());
		   adm.setFechaCreacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));		   
		   AdmMgr.add(adm);
		   code = AdmMgr.getPkColValue("secuencia");
	    }
		else if (modeAdm.equalsIgnoreCase("edit"))
		{	    
		   adm.setUsuarioModificacion(UserDet.getUserEmpId());
		   adm.setFechaModificacion(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		   AdmMgr.update(adm);
		}		
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form1.errCode.value = '<%=AdmMgr.getErrCode()%>';
  parent.document.form1.errMsg.value = '<%=AdmMgr.getErrMsg()%>';
  parent.document.form1.submit(); 
}
</script>
</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>