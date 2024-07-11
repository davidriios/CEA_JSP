<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="eHash" scope="session" class="java.util.Hashtable" />
<%
/**
==================================================================================

==================================================================================
**/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),"") || SecMgr.checkAccess(session.getId(),"800024"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList list = new ArrayList();
ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String provincia = "";
String sigla = "";
String tomo = "";
String asiento = "";
String numEmpleado = "";
String area = "";
String desdeIni = "";
String desdeFin = "";
String change = request.getParameter("change");
String key = "";

if (request.getParameter("provincia")!= null && !request.getParameter("provincia").equalsIgnoreCase("")) provincia = request.getParameter("provincia");
if (request.getParameter("sigla")!= null && !request.getParameter("sigla").equalsIgnoreCase("")) sigla = request.getParameter("sigla");
if (request.getParameter("tomo")!= null && !request.getParameter("tomo").equalsIgnoreCase("")) tomo = request.getParameter("tomo");
if (request.getParameter("asiento")!= null && !request.getParameter("asiento").equalsIgnoreCase("")) asiento = request.getParameter("asiento");
if (request.getParameter("numEmpleado")!= null && !request.getParameter("numEmpleado").equalsIgnoreCase("")) numEmpleado = request.getParameter("numEmpleado");
if (request.getParameter("area")!= null && !request.getParameter("area").equalsIgnoreCase("")) area = request.getParameter("area");

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int recsPerPage = 100;
  String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFrom = "SVF", searchValTo = "SVT", searchValFromDate = "SVFD", searchValToDate = "SVTD";
  if (request.getParameter("searchQuery") != null)
  {
    nextVal = request.getParameter("nextVal");
    previousVal = request.getParameter("previousVal");
    if (!request.getParameter("searchOn").equals("SO")) searchOn = request.getParameter("searchOn");
    if (!request.getParameter("searchVal").equals("Todos")) searchVal = request.getParameter("searchVal");
    if (!request.getParameter("searchType").equals("ST")) searchType = request.getParameter("searchType");
    if (!request.getParameter("searchDisp").equals("SD")) searchDisp = request.getParameter("searchDisp");
		if (!request.getParameter("searchValFromDate").equals("SVFD")) searchValFromDate = request.getParameter("searchValFromDate");
		if (!request.getParameter("searchValToDate").equals("SVTD")) searchValToDate = request.getParameter("searchValToDate");
  }

	if (request.getParameter("fecha") != null)
	{
	   appendFilter += " and upper(to_char(a.fecha,'dd/mm/yyyy')) like '%"+request.getParameter("fecha").toUpperCase()+"%'";

       searchOn = "to_char(a.fecha,'dd/mm/yyyy')";
       searchVal = request.getParameter("fecha");
       searchType = "1";
       searchDisp = "Fecha";
	}
	else if (request.getParameter("desdeIni") != null && request.getParameter("desdeFin") != null)
	{
	   appendFilter += " and to_char(a.hora_entrada,'hh24:mi:ss') between '"+request.getParameter("desdeIni")+"' and '"+request.getParameter("desdeFin")+"'";

	   searchOn = "a.hora_entrada";
	   searchValFromDate = request.getParameter("desdeIni");
       searchValToDate = request.getParameter("desdeFin");
	   searchType = "1";
	   searchDisp = "Hora Entrada";
	}
	else if (request.getParameter("hastaIni") != null && request.getParameter("hastaFin") != null)
	{
	   appendFilter += " and to_char(a.hora_salida,'hh24:mi:ss') between '"+request.getParameter("hastaIni")+"' and '"+request.getParameter("hastaFin")+"'";

	   searchOn = "a.hora_salida";
	   searchValFromDate = request.getParameter("hastaIni");
       searchValToDate = request.getParameter("hastaFin");
	   searchType = "1";
	   searchDisp = "Hora Salida";
	}	
	else if (request.getParameter("searchQuery") != null && !request.getParameter("searchOn").equals("Todos") && (!request.getParameter("searchVal").equals("SV") || (!request.getParameter("searchValFrom").equals("SVF") && !request.getParameter("searchValTo").equals("SVT"))) && !request.getParameter("searchType").equals("ST"))
  {
    if (searchType.equals("1"))
    {
	   appendFilter += " and upper("+searchOn+") like '%"+searchVal.toUpperCase()+"%'";
    }
  }
  else
  {
    searchOn="SO";
    searchVal="Todos";
    searchType="ST";
    searchDisp="Listado";
  }
  if (change==null)	
  {
	sql = "SELECT a.codigo, to_char(a.fecha,'dd/mm/yyyy') as fecha, to_char(a.hora_entrada,'hh24:mi:ss') as hora_entrada, to_char(a.hora_salida,'hh24:mi:ss') as hora_salida, decode(a.tiempo_horas,null,' ',a.tiempo_horas) as tiempo_horas, decode(a.tiempo_minutos,null,' ',a.tiempo_minutos) as tiempo_minutos, decode(a.mfalta,null,' ',a.mfalta) as mfalta, b.descripcion as mfaltaDesc, decode(a.estado,'ND','No Descontar','DS','Descontar') as estatus, a.estado, decode(a.lugar,null,' ',a.lugar) as lugar, nvl(a.lugar_nombre,' ') as lugar_nombre, nvl(a.motivo,' ') as motivo, a.forma_des, nvl(a.aprobado,'N') as aprobado FROM tbl_pla_incapacidad a, tbl_pla_motivo_falta b WHERE a.compania="+(String) session.getAttribute("_companyId")+" and a.provincia="+provincia+" and a.sigla='"+sigla+"' and a.tomo="+tomo+" and a.asiento="+asiento+" and a.ue_codigo="+area+" and a.num_empleado='"+numEmpleado+"' and a.mfalta=b.codigo(+)"+appendFilter;	
	
	al = SQLMgr.getDataList(sql);
	
	eHash.clear(); 	  
	  
	for (int i = 1; i <= al.size(); i++)
	{
	  if (i < 10) key = "00" + i;
	  else if (i < 100) key = "0" + i;
	  else key = "" + i;
	
	  eHash.put(key, al.get(i-1));
	}
  }	
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Planilla - Listado de Incapacidad - '+document.title;

function saveMethod(formName,val)
{
    setBAction(formName,val); 
}
function removeItem(fName,k)
{
    alert('removeItem');
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}
function setBAction(fName,actionValue)
{
    alert('setBAction');
	document.forms[fName].baction.value = actionValue;
}
function detail(i)
{ 
    var fecha;
	var codigo;
	
	fecha = eval('document.formEmpl.fecha'+i).value;
	codigo = eval('document.formEmpl.codigo'+i).value;
	 
    abrir_ventana2('../rhplanilla/incapacidad_detail.jsp?provincia=<%=provincia%>&sigla=<%=sigla%>&tomo=<%=tomo%>&asiento=<%=asiento%>&numEmpleado=<%=numEmpleado%>&area=<%=area%>&fecha='+fecha+'&codigo='+codigo); 
}
function printList()
{
	abrir_ventana('../rhplanilla/print_list_empl_incapacidad.jsp');
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<%@ include file="../common/header.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="PLANILLA - TRANSACCION - LISTADO INCAPACIDAD"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="0" cellspacing="0">
			<tr class="TextFilter">		
				<%
				fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("provincia",provincia)%>
				<%=fb.hidden("sigla",sigla)%>
				<%=fb.hidden("tomo",tomo)%>
				<%=fb.hidden("asiento",asiento)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("area",area)%>
				<td width="19%">Fecha
								<jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="1"/>
								<jsp:param name="clearOption" value="true"/>
								<jsp:param name="nameOfTBox1" value="fecha"/>
								<jsp:param name="valueOfTBox1" value=""/>
								</jsp:include>
				<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
		
				<%
				fb = new FormBean("search02",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("provincia",provincia)%>
				<%=fb.hidden("sigla",sigla)%>
				<%=fb.hidden("tomo",tomo)%>
				<%=fb.hidden("asiento",asiento)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("area",area)%>
				<td width="41%">Hra Entrada
				                <jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2" />
								<jsp:param name="nameOfTBox1" value="desdeIni" />
								<jsp:param name="valueOfTBox1" value="" />
								<jsp:param name="nameOfTBox2" value="desdeFin" />
								<jsp:param name="valueOfTBox2" value="" />
								<jsp:param name="format" value="hh24:mi:ss" />
								</jsp:include>
				<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
				
				<%
				fb = new FormBean("search03",request.getContextPath()+"/common/urlRedirect.jsp");
				%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("provincia",provincia)%>
				<%=fb.hidden("sigla",sigla)%>
				<%=fb.hidden("tomo",tomo)%>
				<%=fb.hidden("asiento",asiento)%>
				<%=fb.hidden("numEmpleado",numEmpleado)%>
				<%=fb.hidden("area",area)%>
				<td width="40%">Hra Salida 
				                <jsp:include page="../common/calendar.jsp" flush="true">
								<jsp:param name="noOfDateTBox" value="2" />
								<jsp:param name="nameOfTBox1" value="hastaIni" />
								<jsp:param name="valueOfTBox1" value="" />
								<jsp:param name="nameOfTBox2" value="hastaFin" />
								<jsp:param name="valueOfTBox2" value="" />
								<jsp:param name="format" value="hh24:mi:ss" />
								</jsp:include>
				<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>		
			</tr>
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableLeftBorder TableRightBorder">

<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

		<table align="center" width="100%" cellpadding="0" cellspacing="1">
		<%fb = new FormBean("formEmpl",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
		<%=fb.formStart(true)%>
		<%=fb.hidden("baction","")%>
		<%=fb.hidden("provincia",provincia)%>
		<%=fb.hidden("sigla",sigla)%>
		<%=fb.hidden("tomo",tomo)%>
		<%=fb.hidden("asiento",asiento)%>
		<%=fb.hidden("numEmpleado",numEmpleado)%>
		<%=fb.hidden("area",area)%>
		<%=fb.hidden("keySize",""+eHash.size())%>	
		
		<tr class="TextHeader" align="center">
			<td width="12%">Fecha</td>
			<td width="10%">Hora Entrada</td>
			<td width="10%">Hora Salida</td>
			<td width="17%">Estado</td>
			<td width="40%">Motivo</td>
			<td width="6%">&nbsp;</td>
			<td width="5%">&nbsp;</td>
		</tr>
		<%
		list = CmnMgr.reverseRecords(eHash);	
		System.out.println("**************************************FORM - eHash.size() = "+eHash.size());			
		for (int i = 1; i <= eHash.size(); i++)
		{
		  key = list.get(i - 1).toString();	
		  CommonDataObject cdo = (CommonDataObject) eHash.get(key);
		  String color = "TextRow02";
		  if (i % 2 == 0) color = "TextRow01";
		%>
		<%=fb.hidden("key"+i,key)%><%=fb.hidden("remove"+i,"")%>   
	    <%=fb.hidden("fecha"+i,cdo.getColValue("fecha"))%>  
		<%=fb.hidden("hora_salida"+i,cdo.getColValue("hora_salida"))%>  
        <%=fb.hidden("hora_entrada"+i,cdo.getColValue("hora_entrada"))%>
		<%=fb.hidden("tiempo_horas"+i,cdo.getColValue("tiempo_horas"))%>    
        <%=fb.hidden("tiempo_minutos"+i,cdo.getColValue("tiempo_minutos"))%>  
        <%=fb.hidden("mfalta"+i,cdo.getColValue("mfalta"))%>  
		<%=fb.hidden("mfaltaDesc"+i,cdo.getColValue("mfaltaDesc"))%>  
		<%=fb.hidden("codigo"+i,cdo.getColValue("codigo"))%>  
		<%=fb.hidden("estado"+i,cdo.getColValue("estado"))%>  
		<%=fb.hidden("lugar_nombre"+i,cdo.getColValue("lugar_nombre"))%>  
		<%=fb.hidden("lugar"+i,cdo.getColValue("lugar"))%>  
        <%=fb.hidden("motivo"+i,cdo.getColValue("motivo"))%>  
        <%=fb.hidden("forma_des"+i,cdo.getColValue("forma_des"))%>  
		<%=fb.hidden("aprobado"+i,cdo.getColValue("aprobado"))%>  

		<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
			<td><%=cdo.getColValue("fecha")%></td>
			<td><%=cdo.getColValue("hora_entrada")%></td>
			<td><%=cdo.getColValue("hora_salida")%></td>
			<td><%=cdo.getColValue("estatus")%></td>
			<td><%=cdo.getColValue("mfaltaDesc")%></td>
			<td><a href="javascript:detail(<%=i%>)" class="Link02Bold" onMouseOver="setoverc(this,'Link01Bold')" onMouseOut="setoutc(this,'Link02Bold')">Detalle</a></td>
			<td align="center"><%=((cdo.getColValue("aprobado").equalsIgnoreCase("N"))?fb.submit("rem"+i,"X",true,false,null,null,"onClick=\"javascript:removeItem('"+fb.getFormName()+"',"+i+")\""):" ")%>&nbsp;</td>
		</tr>
		<%
		}
		%>
		<tr>
		    <td class="TextRow01" colspan="7" align="right"><%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:saveMethod('"+fb.getFormName()+"',this.value)\"","Guardar")%></td>
		</tr>
		<%=fb.formEnd(true)%>
		</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

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
   System.out.println("************************************************POST");
   int keySize=Integer.parseInt(request.getParameter("keySize"));	   	  
   String ItemRemoved = "";	  
   provincia = request.getParameter("provincia");
   sigla = request.getParameter("sigla");
   tomo = request.getParameter("tomo");
   asiento = request.getParameter("asiento");
   numEmpleado = request.getParameter("numEmpleado");
   area = request.getParameter("area");
   System.out.println("************************************************POST - BEFORE CYCLE");
   
   for (int i=1; i<=keySize; i++)
   {
      CommonDataObject cdo = new CommonDataObject();
	  
      cdo.setTableName("tbl_pla_incapacidad"); 
	  cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area+" and provincia="+provincia+" and sigla='"+sigla+"' and tomo="+tomo+" and asiento="+asiento+" and num_empleado="+numEmpleado);
	  cdo.addColValue("ue_codigo",area);
	  cdo.addColValue("provincia",provincia);
	  cdo.addColValue("sigla",sigla);
	  cdo.addColValue("tomo",tomo); 
	  cdo.addColValue("asiento",asiento);
	  cdo.addColValue("compania",(String) session.getAttribute("_companyId"));
	  cdo.addColValue("num_empleado",numEmpleado);
	  System.out.println("**************************************************************POST - INSIDE CYCLE - BEFORE FECHA");
	  cdo.addColValue("fecha",request.getParameter("fecha"+i));
	  cdo.addColValue("hora_salida",request.getParameter("hora_salida"+i));
	  cdo.addColValue("hora_entrada",request.getParameter("hora_entrada"+i));
	  cdo.addColValue("tiempo_horas",request.getParameter("tiempo_horas"+i));
	  cdo.addColValue("tiempo_minutos",request.getParameter("tiempo_minutos"+i));
	  cdo.addColValue("mfalta",request.getParameter("mfalta"+i));
	  cdo.addColValue("mfaltaDesc",request.getParameter("mfaltaDesc"+i));
	  cdo.addColValue("codigo",request.getParameter("codigo"+i));
	  cdo.addColValue("estado",request.getParameter("estado"+i)); 
	  cdo.addColValue("lugar_nombre",request.getParameter("lugar_nombre"+i));
	  cdo.addColValue("lugar",request.getParameter("lugar"+i));
	  cdo.addColValue("motivo",request.getParameter("motivo"+i));
	  cdo.addColValue("forma_des",request.getParameter("forma_des"+i));
	  cdo.addColValue("aprobado",request.getParameter("aprobado"+i));
				 
	  key = request.getParameter("key"+i); 	
	  
	  if (request.getParameter("remove"+i) != null && request.getParameter("remove"+i).equalsIgnoreCase("X"))
	  {  System.out.println("************************************************POST - INSIDE CYCLE - if (request.getParameter(remove))"); 
	     ItemRemoved = key;		 
	  }
	  else
	  {
		 try{ System.out.println("************************************************POST - INSIDE CYCLE - eHash.put()");
		      eHash.put(key,cdo);
			  al.add(cdo);
			}catch(Exception e){ System.err.println(e.getMessage()); }			    	       
      }
	
	  if (!ItemRemoved.equals(""))
	  {
	     System.out.println("************************************************POST - INSIDE CYCLE - eHash.get(ItemRemoved)");
		 eHash.remove(ItemRemoved);	       
		 response.sendRedirect("../rhplanilla/list_empl_incapacidad.jsp?change=1&area="+area+"&provincia="+provincia+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&numEmpleado="+numEmpleado);
		 return;
	  }     
   }
   if (al.size() == 0)
   {
	  CommonDataObject cdo = new CommonDataObject();

	  cdo.setTableName("tbl_pla_incapacidad"); 
	  cdo.setWhereClause("compania= "+(String) session.getAttribute("_companyId")+" and ue_codigo="+area+" and provincia="+provincia+" and sigla='"+sigla+"' and tomo="+tomo+" and asiento="+asiento+" and num_empleado="+numEmpleado);

	  al.add(cdo); 
   }
   System.out.println("********************************************************POST - BEFORE SQLMgr.insertList(al)");
   SQLMgr.insertList(al);   
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
<%
	if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/list_empl_incapacidad.jsp?change=1&area="+area+"&provincia="+provincia+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&numEmpleado="+numEmpleado))
	{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/list_empl_incapacidad.jsp?change=1&area="+area+"&provincia="+provincia+"&sigla="+sigla+"&tomo="+tomo+"&asiento="+asiento+"&numEmpleado="+numEmpleado)%>';
<%
	}
%>
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
