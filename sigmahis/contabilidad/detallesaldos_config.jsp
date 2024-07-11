<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Hashtable"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.contabilidad.DetalleSaldo"%>
<%@ page import="issi.contabilidad.SaldoCta"%>
<%@ page import="ibiz.dbutils.SQL2BeanBuilder"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashDet" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="SaldoMgr" scope="page" class="issi.contabilidad.SaldoCtaMgr" />
<%
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0")|| SecMgr.checkAccess(session.getId(),"900098")|| SecMgr.checkAccess(session.getId(),"900099")|| SecMgr.checkAccess(session.getId(),"900100"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SaldoMgr.setConnection(ConMgr);
SQL2BeanBuilder sbb = new SQL2BeanBuilder();

ArrayList al = new ArrayList();
ArrayList lista = new ArrayList();
String key = "";
String sql = "";
int lastLineNo = 0;
if (request.getParameter("lastLineNo") != null && !request.getParameter("lastLineNo").equals("")) lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
else lastLineNo = 0;
String mode = request.getParameter("mode");
if(mode == null) mode ="";
boolean viewMode = false;
if(mode.equals("view")) viewMode=true;
 
if (request.getMethod().equalsIgnoreCase("GET"))
{  
%>
<html>   
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Detalle Saldo de Ctas Financieras - '+document.title;

function doSubmit()
{
   document.formDetalle.anio.value = parent.document.form1.anio.value;
   document.formDetalle.cta1_p.value = parent.document.form1.cta1.value;
   document.formDetalle.cta2_p.value = parent.document.form1.cta2.value;
   document.formDetalle.cta3_p.value = parent.document.form1.cta3.value;
   document.formDetalle.cta4_p.value = parent.document.form1.cta4.value;
   document.formDetalle.cta5_p.value = parent.document.form1.cta5.value;
   document.formDetalle.cta6_p.value = parent.document.form1.cta6.value;
   document.formDetalle.montoDb_p.value = parent.document.form1.montoDb.value;
   document.formDetalle.montoCr_p.value = parent.document.form1.montoCr.value; 
   document.formDetalle.saldoAct.value = parent.document.form1.saldoAct.value;
   document.formDetalle.saldoIni.value = parent.document.form1.saldoIni.value;
   document.formDetalle.status.value = parent.document.form1.status.value;
   document.formDetalle.saldoAnte.value = parent.document.form1.saldoAnte.value;
   document.formDetalle.submit(); 
}
function newHeight()
{
  if (parent.adjustIFrameSize) parent.adjustIFrameSize(window);
}
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0" onLoad="newHeight();">
<table align="center" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableBorder">
			<table align="center" width="100%" cellpadding="0" cellspacing="1">		
<!-- ================================   F O R M   S T A R T   H E R E   ================================ -->
			<%fb = new FormBean("formDetalle",request.getContextPath()+request.getServletPath(),FormBean.POST);%>
			<%=fb.formStart(true)%>		
			<%=fb.hidden("lastLineNo",""+lastLineNo)%>
			<%=fb.hidden("anio", "")%>
			<%=fb.hidden("keySize",""+HashDet.size())%>			
			<%=fb.hidden("cta1_p", "")%>
			<%=fb.hidden("cta2_p", "")%>
			<%=fb.hidden("cta3_p", "")%>
			<%=fb.hidden("cta4_p", "")%>
			<%=fb.hidden("cta5_p", "")%>
			<%=fb.hidden("cta6_p", "")%>
			<%=fb.hidden("status", "")%>
			<%=fb.hidden("saldoIni", "")%>
			<%=fb.hidden("montoDb_p", "")%>
			<%=fb.hidden("montoCr_p", "")%>			
			<%=fb.hidden("saldoAct", "")%>
			<%=fb.hidden("saldoAnte", "")%>
			    
				<tr class="TextRow02">
					<td colspan="6" align="right">&nbsp;</td>
				</tr>	
			    <tr class="TextHeader" align="center">
					<td width="12%">Mes</td>
					<td width="22%">Saldo Inicial</td>
					<td width="22%">D&eacute;bito</td>							
					<td width="22%">Cr&eacute;dito</td>
					<td width="22%">Saldo Final</td>
				</tr>			
				<%			  
				  if (HashDet.size() > 0) 
				  {  
				    al = CmnMgr.reverseRecords(HashDet);				
				    for (int i = 1; i <= HashDet.size(); i++)
				    {
					  key = al.get(i - 1).toString();									  
				   	  DetalleSaldo co = (DetalleSaldo) HashDet.get(key);					  					  
			    %>		
				 <tr class="TextRow01"><%=fb.hidden("key"+i,key)%>
				 <%=fb.hidden("fechaCrea"+i,co.getFechaCrea())%>
				 <%=fb.hidden("userCrea"+i,co.getUserCrea())%>
				 <%=fb.hidden("key"+i,key)%>
				 <%=fb.hidden("statusIni"+i,co.getStatusIni())%>
				 <%=fb.hidden("statusFin"+i,co.getStatusFin())%>
					 <td><%=fb.intBox("mes"+i,co.getMes(),true,false,true,8)%></td>	
					 <td><%=fb.decBox("montoIni"+i,co.getMontoIni(),true,false,viewMode,22)%></td>
					 <td><%=fb.decBox("montoDb"+i,co.getMontoDb(),true,false,viewMode,22)%></td>
					 <td><%=fb.decBox("montoCr"+i,co.getMontoCr(),true,false,viewMode,22)%></td>
					 <td><%=fb.decBox("montoFin"+i,co.getMontoFin(),true,false,viewMode,22)%></td>					 
				 </tr>															

				<%	
				    }				  
				  }	
				%>  				 	
            <%=fb.formEnd(true)%>
			
<!-- ================================   F O R M   E N D   H E R E   ================================ -->

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
	  int keySize=Integer.parseInt(request.getParameter("keySize"));	   
	  lastLineNo = Integer.parseInt(request.getParameter("lastLineNo"));
	  ArrayList list = new ArrayList();	  
	  String ItemRemoved = "";
	    	   	  
	 for (int i=1; i<=keySize; i++)
	  {
	    DetalleSaldo co = new DetalleSaldo();

	    co.setMes(request.getParameter("mes"+i));
		co.setStatusIni(request.getParameter("statusIni"+i));
		co.setStatusFin(request.getParameter("statusFin"+i));
		co.setMontoIni(request.getParameter("montoIni"+i));
		co.setMontoDb(request.getParameter("montoDb"+i));
		co.setMontoCr(request.getParameter("montoCr"+i));
		co.setMontoFin(request.getParameter("montoFin"+i));
		
		co.setAnio(request.getParameter("anio"));	 
		co.setCta1(request.getParameter("cta1_p"));
		co.setCta2(request.getParameter("cta2_p"));
		co.setCta3(request.getParameter("cta3_p"));
		co.setCta4(request.getParameter("cta4_p"));
		co.setCta5(request.getParameter("cta5_p"));
		co.setCta6(request.getParameter("cta6_p"));
		co.setCompania((String) session.getAttribute("_companyId"));
						
		co.setUserCrea(request.getParameter("userCrea"+i)); 
		co.setFechaCrea(request.getParameter("fechaCrea"+i));
		co.setUserMod(UserDet.getUserEmpId()); 
		co.setFechaMod(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		 
	    key = request.getParameter("key"+i);
		
		if (request.getParameter("remove"+i)== null)
		{ 
		try{ 
		  HashDet.put(key, co);
		  list.add(co);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		 }
		 else
		 {
	      ItemRemoved = key;			    	       
	    }
	  }	
	
	  if (!ItemRemoved.equals(""))
	  {
	     HashDet.remove(ItemRemoved);
		 response.sendRedirect("../contabilidad/detallesaldos_config.jsp?lastLineNo="+lastLineNo);
		 return;
	  }
	  /*		
	  if (request.getParameter("addCol") != null)
	  {	
		DetalleSaldo co = new DetalleSaldo();
		co.setUserCrea(UserDet.getUserEmpId()); 
		co.setFechaCrea(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		co.setUserMod(UserDet.getUserEmpId()); 
		co.setFechaMod(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));
		
		++lastLineNo;
	    if (lastLineNo < 10) key = "00" + lastLineNo;
	    else if (lastLineNo < 100) key = "0" + lastLineNo;
	    else key = "" + lastLineNo;
		
		co.setMes(""+lastLineNo);
		
		try{ 
		    HashDet.put(key, co);
		   }catch(Exception e){ System.err.println(e.getMessage()); }	 
		response.sendRedirect("../contabilidad/detallesaldos_config.jsp?mode="+mode+"&lastLineNo="+lastLineNo);
		return;
	  }*/
		 SaldoCta sald = new SaldoCta();
		 
		 sald.setAnio(request.getParameter("anio"));	 
		 sald.setCta1(request.getParameter("cta1_p"));
		 sald.setCta2(request.getParameter("cta2_p"));
		 sald.setCta3(request.getParameter("cta3_p"));
		 sald.setCta4(request.getParameter("cta4_p"));
		 sald.setCta5(request.getParameter("cta5_p"));
		 sald.setCta6(request.getParameter("cta6_p"));
		 sald.setCompania((String) session.getAttribute("_companyId"));
		 sald.setMontoDb(request.getParameter("montoDb_p"));
		 sald.setMontoCr(request.getParameter("montoCr_p"));		 
		 sald.setSaldoAct(request.getParameter("saldoAct"));
		 sald.setSaldoIni(request.getParameter("saldoIni"));
		 sald.setSaldoAnte(request.getParameter("saldoAnte"));
		 sald.setStatus(request.getParameter("status"));
		 sald.setUserMod(UserDet.getUserEmpId());
		 sald.setFechaMod(CmnMgr.getCurrentDate("dd/mm/yyyy hh24:mi:ss"));	
		 			
		 sald.setDetalle(list);
		 		 
		 SaldoMgr.update(sald);
%>
<html>
<head>
<script language="javascript" src="../js/capslock.js"></script>
<script language="javascript">
function closeWindow()
{
  parent.document.form1.errCode.value = '<%=SaldoMgr.getErrCode()%>';
  parent.document.form1.errMsg.value = '<%=SaldoMgr.getErrMsg()%>';
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