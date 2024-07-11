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
<jsp:useBean id="htdesc" scope="session" class="java.util.Hashtable"/>
<%

SecMgr.setConnection(ConMgr);
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
CommonDataObject grp= new CommonDataObject();
String sql = "";
String mode = request.getParameter("mode");
String nombre = request.getParameter("nombre");
String desde = request.getParameter("desde");
String hasta = request.getParameter("hasta");
String compania = (String) session.getAttribute("_companyId");
String change= request.getParameter("change");
String key = "";
int desclastLineNo =0;

if(request.getParameter("desclastLineNo")!=null && ! request.getParameter("desclastLineNo").equals(""))
desclastLineNo=Integer.parseInt(request.getParameter("desclastLineNo"));
else desclastLineNo=0;

if (mode == null) mode = "add";

if (request.getMethod().equalsIgnoreCase("GET"))
{

	if (mode.equalsIgnoreCase("add"))
	{
		nombre = "";
	}
	else
	{


	sql = "select distinct(to_char(desde,'dd/mm/yyyy')) desde, to_char(hasta,'dd/mm/yyyy') hasta, nombre from tbl_pla_li_rango_indemn where nombre = '"+nombre+"'";
			grp = SQLMgr.getData(sql);

if(change==null)
	{
	sql = "select to_char(desde,'dd/mm/yyyy') desde, to_char(hasta,'dd/mm/yyyy') hasta, nombre, ri_anios, ri_meses, rf_anio, rf_meses, valor_fijo, decode(tipo_fijo,'S','SEMANAS','M','MESES','A','AÑOS') desctipo_fijo, tipo_fijo, valor_adic, decode(tipo_adic,'S','SEMANAS','M','MESES','A','AÑOS') desctipo_adic, tipo_adic, frec_adic,  decode(tipo_frec, 'S', 'SEMANAS', 'M', 'MESES','A','AÑOS') desctipo_frec, tipo_frec from tbl_pla_li_rango_indemn  where nombre = '"+nombre+"'";

		al=SQLMgr.getDataList(sql);

		htdesc.clear();
		desclastLineNo=0;
			for(int h=0;h<al.size();h++)
			{
				desclastLineNo++;

				if(desclastLineNo<10)
						key="00" + desclastLineNo;
				else if(desclastLineNo<100)
						key="0" + desclastLineNo;
				else
						key="" + desclastLineNo;
				htdesc.put(key,al.get(h));
			}
		}
	}
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<%@ include file="../common/calendar_base.jsp" %>
<script language="javascript">
document.title = 'Planilla - '+document.title;

function setBAction(fName,actionValue)
{
	document.forms[fName].baction.value = actionValue;
}

function removeItem(fName,k)
{
	var rem = eval('document.'+fName+'.rem'+k).value;
	eval('document.'+fName+'.remove'+k).value = rem;
	setBAction(fName,rem);
}

</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Motivos de Terminación de Contratos"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="0" cellspacing="0">
<tr>
	<td class="TableBorder">
		<table align="center" width="99%" cellpadding="0" cellspacing="1">

<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
	<%fb = new FormBean("form",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
	<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
<%=fb.formStart(true)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("compania",compania)%>
<%=fb.hidden("baction","")%>
<%=fb.hidden("desclastLineNo",""+desclastLineNo)%>
<%=fb.hidden("keySize",""+htdesc.size())%>
			<%=fb.hidden("desde1",desde)%>
			<%=fb.hidden("hasta1",hasta)%>
			<%=fb.hidden("nombre1",nombre)%>
		<tr>
			<td colspan="11">&nbsp;</td>
		</tr>
		<tr class="TextRow02">
			<td colspan="11">&nbsp;</td>
		</tr>
		<tr class="TextRow01">
			<td colspan="3" align="left">Nombre del Rango : </td>
			<td colspan="8" align="left"><%=fb.textBox("nombreRango",grp.getColValue("nombre"),true,false,false,65,null,null,"")%></td>
		</tr>
			<tr class="TextRow02">
			<td colspan="3" align="center">Para Tiempo de Servicio Entre</td>
			<td colspan="3" align="center">Desde :
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="desdeFec" />
				<jsp:param name="valueOfTBox1" value="<%=(grp.getColValue("desde")==null)?"":grp.getColValue("desde")%>" />
				</jsp:include>
			</td>



			<td colspan="5" align="left">Hasta :
				<jsp:include page="../common/calendar.jsp" flush="true">
				<jsp:param name="noOfDateTBox" value="1" />
				<jsp:param name="nameOfTBox1" value="hastaFec" />
				<jsp:param name="valueOfTBox1" value="<%=(grp.getColValue("hasta")==null)?"":grp.getColValue("hasta")%>" />
				</jsp:include>
			</td>

		</tr>
				<tr class="TextRow01">
			<td colspan="2" align="center">Rango Inicial</td>
			<td colspan="2" align="center">Rango Final</td>
			<td colspan="2" align="center">Valor Fijo</td>
			<td colspan="2" align="center">Valor Adicional</td>
			<td colspan="3" align="center">Frecuencia del Valor Adic.</td>
		</tr>

		<tr class="TextRow02">
			<td width="7%" align="center">Años</td>
			<td width="8%" align="center">Meses</td>
			<td width="8%" align="center">Años</td>
			<td width="8%" align="center">Meses</td>
			<td width="8%" align="center">Cant.</td>
			<td width="15%" align="center">Tipo</td>
			<td width="8%" align="center">Cant.</td>
			<td width="15%" align="center">Tipo</td>
			<td width="8%" align="center">Cant.</td>
			<td width="10%" align="center">Tipo</td>
			<td width="5%" align="center"><%=fb.submit("btnagregar","+",false,false)%></td>
		</tr>
	<%
			String codigo="0";
			if(htdesc.size()>0)
			al=CmnMgr.reverseRecords(htdesc);

	for (int i=0; i<al.size(); i++)
	{
			key = al.get(i).toString();
			CommonDataObject cdos = (CommonDataObject) htdesc.get(key);

			String color = "";

			if (i%2 == 0) color = "TextRow02";
			else color = "TextRow01";
			boolean readonly = true;
	%>
					<%=fb.hidden("key"+i,key)%>
					<%=fb.hidden("desde"+i,cdos.getColValue("desde"))%>
					<%=fb.hidden("hasta"+i,cdos.getColValue("hasta"))%>
					<%=fb.hidden("nombre"+i,cdos.getColValue("nombre"))%>

		<tr class="TextRow01">
			<td align="center"><%=fb.textBox("ri_anios"+i,cdos.getColValue("ri_anios"),true,false,false,5,null,null,"")%></td>
			<td align="left"><%=fb.textBox("ri_meses"+i,cdos.getColValue("ri_meses"),true,false,false,5,null,null,"")%></td>
			<td align="center"><%=fb.textBox("rf_anio"+i,cdos.getColValue("rf_anio"),true,false,false,5,null,null,"")%></td>
			<td align="left"><%=fb.textBox("rf_meses"+i,cdos.getColValue("rf_meses"),true,false,false,5,null,null,"")%></td>
			<td align="center"><%=fb.textBox("valor_fijo"+i,cdos.getColValue("valor_fijo"),false,false,false,5,null,null,"")%></td>
			<td><%=fb.select("tipo_fijo"+i,"A=AÑOS,M=MESES,S=SEMANAS",cdos.getColValue("tipo_fijo"))%></td>
			<td align="center"><%=fb.textBox("valor_adic"+i,cdos.getColValue("valor_adic"),false,false,false,5,null,null,"")%></td>
			<td><%=fb.select("tipo_adic"+i,"A=AÑOS,M=MESES,S=SEMANAS",cdos.getColValue("tipo_adic"))%></td>
			<td align="center"><%=fb.textBox("frec_adic"+i,cdos.getColValue("frec_adic"),false,false,false,5,null,null,"")%></td>
			<td><%=fb.select("tipo_frec"+i,"A=AÑOS,M=MESES,S=SEMANAS",cdos.getColValue("tipo_frec"))%></td>
			<td align="center"><%=fb.submit("remover"+i,"X",false,false)%></td>
		</tr>

		<%  } %>

		<tr class="TextRow02">
			<td colspan="11">&nbsp;</td>
		</tr>

		<tr class="TextRow02">
						 <td align="right" colspan="11"> Opciones de Guardar:

						<%=fb.radio("saveOption","O")%>Mantener Abierto
						<%=fb.radio("saveOption","C",true,false,false)%>Cerrar
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction('"+fb.getFormName()+"',this.value)\"")%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
						</td>
		</tr>


		<tr>
			<td colspan="10">&nbsp;</td>
		</tr>
<%=fb.formEnd(true)%>
 <%=fb.hidden("keySize",""+al.size())%>

<!-- ====================   F O R M   E N D   H E R E   ================ -->

		</table>
	</td>
</tr>
</table>
<%@ include file="../common/footer.jsp"%>
</body>
</html>
<%
}//GET
if(request.getMethod().equalsIgnoreCase("POST"))
{

	String saveOption = request.getParameter("saveOption");//N=Create New,O=Keep Open,C=Close
	String baction = request.getParameter("baction");

	nombre   = request.getParameter("nombreRango");
	desde   = request.getParameter("desdeFec");
	hasta   = request.getParameter("hastaFec");
	String tipoFi= "";
	String tipoAd= "";
	String tipoFr= "";
	ArrayList list= new ArrayList();
	int keySize = Integer.parseInt(request.getParameter("keySize"));
	String itemRemoved = "";

	htdesc.clear();
	for(int a=0; a<keySize; a++)
	{
		CommonDataObject cdo = new CommonDataObject();

		cdo.setTableName("tbl_pla_li_rango_indemn");
		cdo.setWhereClause("nombre='"+request.getParameter("nombre"+a)+"'");

		cdo.addColValue("nombre",nombre);
		cdo.addColValue("desde",desde);
		cdo.addColValue("hasta",hasta);
		cdo.addColValue("ri_anios",request.getParameter("ri_anios"+a));
		cdo.addColValue("ri_meses",request.getParameter("ri_meses"+a));
		cdo.addColValue("rf_anio",request.getParameter("rf_anio"+a));
		cdo.addColValue("rf_meses",request.getParameter("rf_meses"+a));
		cdo.addColValue("valor_fijo",request.getParameter("valor_fijo"+a));
		cdo.addColValue("tipo_fijo",request.getParameter("tipo_fijo"+a));
		cdo.addColValue("valor_adic",request.getParameter("valor_adic"+a));
		cdo.addColValue("tipo_adic",request.getParameter("tipo_adic"+a));
		cdo.addColValue("tipo_frec",request.getParameter("tipo_frec"+a));
		cdo.addColValue("frec_adic",request.getParameter("frec_adic"+a));
		key=request.getParameter("key"+a);

					if(request.getParameter("remover"+a)==null)
					{
						try
						{
						htdesc.put(key,cdo);
						list.add(cdo);
						}
						catch(Exception e)
						{
						 System.err.println(e.getMessage());
						}
					}
					else itemRemoved= key;
 }//End For

					if(!itemRemoved.equals(""))
					{
						htdesc.remove(itemRemoved);
							response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode=edit&change=1&nombre="+nombre+"&desclastLineNo="+desclastLineNo+"&desde="+desde+"&hasta="+hasta);
					//response.sendRedirect("../rhplanilla/descuento_config.jsp?change=1&desclastLineNo="+desclastLineNo+"&emp_id="+emp_id);
					return;
					}

		if(request.getParameter("btnagregar")!=null)
		{
		CommonDataObject cdo = new CommonDataObject();

		cdo.addColValue("ri_anios","");
		cdo.addColValue("ri_meses","");
		cdo.addColValue("rf_anio","");
		cdo.addColValue("rf_meses","");
				desclastLineNo++;

		if(desclastLineNo<10)
		key="00" + desclastLineNo;
		else if(desclastLineNo<100)
		key="0"+desclastLineNo;
		else key=""+desclastLineNo;
		htdesc.put(key,cdo);
//response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1&nombre="+nombre+"&desclastLineNo="+desclastLineNo);
response.sendRedirect(request.getContextPath()+request.getServletPath()+"?mode=edit&change=1&nombre="+nombre+"&desclastLineNo="+desclastLineNo+"&desde="+desde+"&hasta="+hasta);
		 return;
		}

		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
						if(keySize==0){
							CommonDataObject cdo = new CommonDataObject();
							cdo.setTableName("tbl_pla_li_rango_indemn");
							//cdo.setWhereClause(" nombre='"+nombre+"' and desde is not null");
							cdo.setWhereClause("nombre='"+request.getParameter("nombre")+"'");
							list.add(cdo);
							SQLMgr.insertList(list, false, true);
							} else SQLMgr.insertList(list);
		ConMgr.clearAppCtx(null);

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
		if (session.getAttribute("_urlInfo") != null && ((Hashtable) session.getAttribute("_urlInfo")).containsKey(request.getContextPath()+"/rhplanilla/rango_idemn_list.jsp"))
		{
%>
	window.opener.location = '<%=(String) ((Hashtable) session.getAttribute("_urlInfo")).get(request.getContextPath()+"/rhplanilla/rango_idemn_list.jsp")%>';
<%
		}
		else
		{
%>
	window.opener.location = '<%=request.getContextPath()%>/rhplanilla/rango_idemn_list.jsp';
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
	window.location = '<%=request.getContextPath()+request.getServletPath()%>';
}

function editMode()
{
	window.location = '<%=request.getContextPath()+request.getServletPath()%>?mode=edit&nombre=<%=nombre%>';
}

</script>

</head>
<body onLoad="closeWindow()">
</body>
</html>
<%
}//POST
%>