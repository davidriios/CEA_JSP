<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="iValCr" scope="session" class="java.util.Hashtable" />
<%

SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");

UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);
String sql = "";
String mode = request.getParameter("mode");
String codigo = request.getParameter("codigo");
String change = request.getParameter("change");
String compania = (String) session.getAttribute("_companyId");
String key = "";
String cDate = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi:ss am");
String cUserName = UserDet.getUserName();
String valoresCriticos = "", codigoValCriticos = "", centroServicio = "";

ArrayList al = new ArrayList();
ArrayList alCds = new ArrayList();
SQL2BeanBuilder sbb = new SQL2BeanBuilder();
StringBuffer sbSql = new StringBuffer();
StringBuffer sbFilter = new StringBuffer(); 

int valCrLastLineNo = 0;

if (mode == null) mode = "add";
if (codigo==null) codigo = "0";

if (request.getParameter("valCrLastLineNo") != null) valCrLastLineNo = Integer.parseInt(request.getParameter("valCrLastLineNo"));

CommonDataObject cdoPaq = new CommonDataObject();

if (request.getMethod().equalsIgnoreCase("GET"))
{
  int rowCount = 0;
  int recsPerPage = 50;
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
	
	alCds = sbb.getBeanList(ConMgr.getConnection(),"select codigo as optValueColumn, codigo||' - '||descripcion as optLabelColumn, codigo as optTitleColumn from tbl_cds_centro_servicio where estado = 'A' and codigo > 0 order by descripcion",CommonDataObject.class);
	
	CommonDataObject cdo = new CommonDataObject();
	
	if (request.getParameter("valoresCriticos")!=null && !request.getParameter("valoresCriticos").trim().equals("")){
	   sbFilter.append(" and descripcion like '%");
	   sbFilter.append(request.getParameter("valoresCriticos"));
	   sbFilter.append("%'");
	   valoresCriticos = request.getParameter("valoresCriticos");
	} 
	
	if (request.getParameter("codigoValCriticos")!=null && !request.getParameter("codigoValCriticos").trim().equals("")){
	   sbFilter.append(" and codigo = ");
	   sbFilter.append(request.getParameter("codigoValCriticos"));
	   codigoValCriticos = request.getParameter("codigoValCriticos");
	} 
	
	if (request.getParameter("centroServicio")!=null && !request.getParameter("centroServicio").trim().equals("")){
	   sbFilter.append(" and cds = ");
	   sbFilter.append(request.getParameter("centroServicio"));
	   centroServicio = request.getParameter("centroServicio");
	} 

	if (change == null){
	
	   iValCr.clear();
	   sbSql.append("select codigo, cds, estado, descripcion,(select count(*) from tbl_sal_val_criticos where codigo_valor = codigo) as lockedd from tbl_sal_cds_val_criticos where compania = ");
	   sbSql.append(compania);
	   sbSql.append(sbFilter.toString());
	   sbSql.append(" order by 1 ");
	   	   
	   al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sbSql.toString()+") a) where rn between "+previousVal+" and "+nextVal);

	   rowCount = CmnMgr.getCount("select count(*) count from ("+sbSql.toString()+")");

	   valCrLastLineNo = al.size();

	   for (int i=0; i<al.size(); i++){
			cdo = (CommonDataObject) al.get(i);
			cdo.setAction("U");
			cdo.setKey(i);

			try
			{
				iValCr.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}//for i

		
		if (al.size() == 0){
			cdo = new CommonDataObject();

			cdo.addColValue("codigo","0");
			cdo.addColValue("lockedd","0");
			cdo.setKey(iValCr.size()+1);
			cdo.addColValue("key",key);
			cdo.setAction("I");

			try
			{
				iValCr.put(cdo.getKey(), cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}
			
	}// change == null
	
	if (searchDisp!=null) searchDisp=searchDisp;
    else searchDisp = "Listado";
    if (!searchVal.equals("")) searchValDisp=searchVal;
    else searchValDisp="Todos";

    int nVal, pVal;
    int preVal=Integer.parseInt(previousVal);
    int nxtVal=Integer.parseInt(nextVal);
    if (nxtVal<=rowCount) nVal=nxtVal;
    else nVal=rowCount;
    if(rowCount==0) pVal=0;
    else pVal=preVal;
%>
<!doctype html>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script>
function doAction(){
  <%if (request.getParameter("type") != null){%>
  <%}%>
}
$(document).ready(function(){
   $(".btnRem").click(function(c){
	 var i = $(this).data("i");
	 removeItem('form1',i);
	 $("#form1").submit();
   });

});

function canSubmit(){
   var s = $("#valCrSize").val() || 0;
   s = parseInt(s);
   for (var i = 0; i<s; i++){
      var desc = $("#descripcion"+i).val();
	  if (!desc) {alert("No puede enviar el valor crítico en blano!"); return false;}
   }
   return true;
}

function printList(){
  abrir_ventana("../expediente/print_exp_cds_valores_criticos.jsp?compania=<%=compania%>&centroServicio="+$("#centroServicio").val()+"&valoresCriticos="+$("#valoresCriticos").val());
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="javascript:doAction()">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="Paquete de Cargos"></jsp:param>
</jsp:include>

<table align="center" width="99%" cellpadding="0" cellspacing="0">

    <tr>
		<td>
			<table width="100%" cellpadding="0" cellspacing="0">
				<tr class="TextFilter">
					<%fb = new FormBean("search01",request.getContextPath()+"/common/urlRedirect.jsp");%>
					<%=fb.formStart(true)%>
					<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
					<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
					<td>
						<cellbytelabel>Centro Servicio</cellbytelabel>:&nbsp;<%=fb.select("centroServicio",alCds,centroServicio,false,false,0,"","width:400px","","","S")%>
						&nbsp;&nbsp;&nbsp;
						<cellbytelabel>Prueba</cellbytelabel>:&nbsp;<%=fb.textBox("valoresCriticos",valoresCriticos,false,false,false,70)%>
						<%=fb.submit("go","Ir")%>
					</td>
					<%=fb.formEnd(true)%>
				</tr>	
			</table>
		</td>
  </tr>
  
  <tr class="TextRow01"><td align="right"><authtype type='0'><a href="javascript:printList()" class="Link00Bold">[ <cellbytelabel>Imprimir</cellbytelabel> ]</a></authtype>
    </td>
  </tr>
  
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%fb = new FormBean("topPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("centroServicio",centroServicio)%>
				<%=fb.hidden("valoresCriticos",valoresCriticos)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				<%fb = new FormBean("topNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("centroServicio",centroServicio)%>
				<%=fb.hidden("valoresCriticos",valoresCriticos)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
				</tr>
			</table>
		</td>
	</tr>

	<tr>
		<td class="TableBorder">
		  <table align="center" width="100%" cellpadding="0" cellspacing="1">
			<%fb = new FormBean("form1",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>
			<%fb.appendJsValidation("if(document."+fb.getFormName()+".baction.value!='Guardar')return true;");%>
			<%=fb.hidden("mode",mode)%>
			<%=fb.hidden("baction","")%>
			<%=fb.hidden("codigo",codigo)%>
			<%=fb.hidden("valCrSize",""+iValCr.size())%>
			<%=fb.hidden("valCrLastLineNo",""+valCrLastLineNo)%>
			<%=fb.hidden("centroServicio",centroServicio)%>
			<%=fb.hidden("valoresCriticos",valoresCriticos)%>
			 <tr class="TextHeader02">
				<td width="45%">Prueba</td>
				<td width="35%">Centro de Servicio</td>
				<td width="15%">Estado</td>
				<td width="5%" align="center">
				<% String form = "'"+fb.getFormName()+"'";%>
				<%=fb.submit("btnAdd","+",false,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"","Agregar Usos")%>
				</td>
			 </tr>

					<%
						al = CmnMgr.reverseRecords(iValCr);
						for (int i=0; i<iValCr.size(); i++)
						{
							key = al.get(i).toString();
							CommonDataObject cdoUsoValCreEsp = (CommonDataObject) iValCr.get(key);
							boolean locked = cdoUsoValCreEsp.getColValue("lockedd")!=null && !cdoUsoValCreEsp.getColValue("lockedd").equals("")&& !cdoUsoValCreEsp.getColValue("lockedd").equals("0");
					%>
						<tr class="TextRow01" id="row<%=i%>">
							<td><%=fb.textBox("descripcion"+i,cdoUsoValCreEsp.getColValue("descripcion"),true,false,locked,90,"",null,null)%></td>
							<td><%=fb.select("cds"+i,alCds,cdoUsoValCreEsp.getColValue("cds"),false,locked,0,"","width:400px","","","")%>
							</td>
							<td><%=fb.select("estado"+i,"A=Activo, I=Inactivo",cdoUsoValCreEsp.getColValue("estado"),false,false,0,"","width:190px",null,"","")%></td>							
							<td align="center"><%=fb.button("rem"+i,"X",true,locked,"btnRem",cdoUsoValCreEsp.getAction().equals("D")?"color:red":"","","Eliminar","data-i='"+i+"'")%></td>
						</tr>
						<%=fb.hidden("key"+i,cdoUsoValCreEsp.getKey())%>
						<%=fb.hidden("remove"+i,"")%>			
						<%=fb.hidden("action"+i,cdoUsoValCreEsp.getAction())%>			
						<%=fb.hidden("codigo"+i,cdoUsoValCreEsp.getColValue("codigo"))%>			
						<%=fb.hidden("lockedd"+i,cdoUsoValCreEsp.getColValue("lockedd"))%>			
					 <%}%>


				 <tr class="TextRow02">
					<td align="right" colspan="6">
						
						<%=fb.submit("save","Guardar",true,false,null,null,"onClick=\"javascript:setBAction("+form+",this.value)\"")%>
					</td>
				</tr>
			<%=fb.formEnd(true)%>
			</table>
		</td>
	</tr>
	
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
				<%fb = new FormBean("bottomPrevious",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal-recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal-recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("centroServicio",centroServicio)%>
				<%=fb.hidden("valoresCriticos",valoresCriticos)%>
				<td width="10%"><%=(preVal != 1)?fb.submit("previous","<<-"):""%></td>
				<%=fb.formEnd()%>
				<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
				<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
				
				<%fb = new FormBean("bottomNext",request.getContextPath()+"/common/urlRedirect.jsp");%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("nextVal",""+(nxtVal+recsPerPage))%>
				<%=fb.hidden("previousVal",""+(preVal+recsPerPage))%>
				<%=fb.hidden("searchOn",searchOn)%>
				<%=fb.hidden("searchVal",searchVal)%>
				<%=fb.hidden("searchValFromDate",searchValFromDate)%>
				<%=fb.hidden("searchValToDate",searchValToDate)%>
				<%=fb.hidden("searchType",searchType)%>
				<%=fb.hidden("searchDisp",searchDisp)%>
				<%=fb.hidden("searchQuery","sQ")%>
				<%=fb.hidden("centroServicio",centroServicio)%>
				<%=fb.hidden("valoresCriticos",valoresCriticos)%>
				<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("next","->>"):""%></td>
				<%=fb.formEnd()%>
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
	String baction = request.getParameter("baction");
	int size = Integer.parseInt(request.getParameter("valCrSize")==null?"0":request.getParameter("valCrSize"));
	String errCode = "";
	String errMsg = "";

	String itemRemoved = "";
		
	al.clear();
	iValCr.clear();
	
	for (int i=0; i<size; i++)
	{
		CommonDataObject cdo = new CommonDataObject();
		cdo.setTableName("tbl_sal_cds_val_criticos");
		
		cdo.addColValue("descripcion",request.getParameter("descripcion"+i));
		cdo.addColValue("cds",request.getParameter("cds"+i));
		cdo.addColValue("compania",compania);
		cdo.addColValue("estado",request.getParameter("estado"+i));
		cdo.addColValue("lockedd",request.getParameter("lockedd"+i));
		
		cdo.addColValue("key",request.getParameter("key"+i));
		cdo.setKey(i);
		cdo.setAction(request.getParameter("action"+i));
		
		if (request.getParameter("codigo"+i)==null || request.getParameter("codigo"+i).equals("0") || request.getParameter("codigo"+i).equals("") ) {
		   cdo.setAutoIncCol("codigo");
		}else{
		  cdo.addColValue("codigo",request.getParameter("codigo"+i));
		  cdo.setWhereClause("codigo = "+request.getParameter("codigo"+i)+" and compania = "+compania);
		}  
		
		if (request.getParameter("remove"+i) != null && !request.getParameter("remove"+i).equals("")){
		    itemRemoved = cdo.getKey();
		    if (cdo.getAction().equalsIgnoreCase("I")) cdo.setAction("X");
			else cdo.setAction("D");
		}
				
		if (!cdo.getAction().equalsIgnoreCase("X"))
		{
			try
			{
				iValCr.put(cdo.getKey(),cdo);
				al.add(cdo);
			}
			catch(Exception e)
			{
				System.err.println(e.getMessage());
			}
		}

	}
	
	if (!itemRemoved.equals("")){
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1");
		return;
	}
	
	if (baction != null && baction.equals("+"))
	{
		CommonDataObject cdo = new CommonDataObject();
		valCrLastLineNo++;
		
		cdo.setKey(iValCr.size()+1);
		cdo.setAction("I");
		cdo.addColValue("codigo","0");
		cdo.addColValue("lockedd","0");
		try
		{
			iValCr.put(cdo.getKey(), cdo);
		}
		catch(Exception e)
		{
			System.err.println(e.getMessage());
		}
		
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?change=1");
		return;
	}

	if(baction != null && baction.equals("Guardar"))
	{
		if (al.size() == 0)
		{
			CommonDataObject cdo = new CommonDataObject();
			cdo.setTableName("tbl_sal_cds_val_criticos");
			cdo.setAction("I");
			al.add(cdo);
		}
		
		ConMgr.setAppCtx(ConMgr.AUDIT_SOURCE,request.getServletPath());
		SQLMgr.saveList(al,true);
		ConMgr.clearAppCtx(null);
	}
%>
<!DOCTYPE html>
<html>
<head>
<script>
function closeWindow()
{
<%
if (SQLMgr.getErrCode().equals("1"))
{
%>
	alert('<%=SQLMgr.getErrMsg()%>');
	window.location = '<%=request.getContextPath()%>/expediente/exp_cds_valores_criticos.jsp';
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