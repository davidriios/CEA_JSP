<%@ page errorPage="../error.jsp"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Hashtable" %>
<%@ page import="java.util.Vector" %>
<%@ page import="issi.admin.CommonDataObject"%>
<%@ page import="issi.admin.FormBean"%>
<%@ page import="issi.admision.Admision"%>
<%@ page import="issi.expediente.HojaMedicamentoDet"%>
<jsp:useBean id="ConMgr" scope="session" class="issi.admin.ConnectionMgr" />
<jsp:useBean id="SecMgr" scope="session" class="issi.admin.SecurityMgr" />
<jsp:useBean id="UserDet" scope="session" class="issi.admin.UserDetail" />
<jsp:useBean id="CmnMgr" scope="page" class="issi.admin.CommonMgr" />
<jsp:useBean id="SQLMgr" scope="page" class="issi.admin.SQLMgr" />
<jsp:useBean id="fb" scope="page" class="issi.admin.FormBean" />
<jsp:useBean id="HashMed" scope="session" class="java.util.Hashtable" />
<jsp:useBean id="vMed" scope="session" class="java.util.Vector" />

<%
/*
==================================================================================
==================================================================================
*/
SecMgr.setConnection(ConMgr);
if (!SecMgr.checkLogin(session.getId())) throw new Exception("Usted está fuera del sistema. Por favor entre al sistema con su nombre de usuario y clave!!!");
//if (!(SecMgr.checkAccess(session.getId(),"0") || SecMgr.checkAccess(session.getId(),"500037") || SecMgr.checkAccess(session.getId(),"500038") || SecMgr.checkAccess(session.getId(),"500039") || SecMgr.checkAccess(session.getId(),"500040"))) throw new Exception("Usted no tiene los suficientes Derechos de Acceso a esta página.");
UserDet = SecMgr.getUserDetails(session.getId());
session.setAttribute("UserDet",UserDet);
issi.admin.ISSILogger.setSession(session);

CmnMgr.setConnection(ConMgr);
SQLMgr.setConnection(ConMgr);

ArrayList al = new ArrayList();
int rowCount = 0;
String sql = "";
String appendFilter = "";
String fp = request.getParameter("fp");
String mode = request.getParameter("mode");
String pacId = request.getParameter("pacId");
String noAdmision = request.getParameter("noAdmision");
String seccion = request.getParameter("seccion");
String from = request.getParameter("from");
String cds = request.getParameter("cds");
String descripcion ="";
int lastLineNo = 0;

if (from == null) from = "";
if (cds == null) cds = "";

if (fp == null) throw new Exception("La Localización Origen no es válida. Por favor intente nuevamente!");
if (request.getParameter("mode") == null) mode = "add";
if (request.getParameter("lastLineNo") != null) lastLineNo   = Integer.parseInt(request.getParameter("lastLineNo"));

StringBuffer sbSql = new StringBuffer();
sbSql.append("select nvl(get_sec_comp_param(");
sbSql.append(session.getAttribute("_companyId"));
sbSql.append(",'EXP_MOSTRAR_MED_HOJAMED'),'N') as mostrar_med_en_hoja_med ");
sbSql.append(" from dual");
CommonDataObject cdoParam = (CommonDataObject) SQLMgr.getData(sbSql.toString());
if (cdoParam == null) cdoParam = new CommonDataObject();

if(request.getMethod().equalsIgnoreCase("GET"))
{
	int recsPerPage=100;
	String nextVal = ""+recsPerPage, previousVal = "1", searchQuery, searchOn = "SO", searchVal = "Todos", searchType = "ST", searchDisp = "SD", searchValDisp = "Todos", searchValFromDate = "SVFD", searchValToDate = "SVTD";
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

  if (request.getParameter("descripcion") != null && !request.getParameter("descripcion").trim().equals(""))
  {
    appendFilter += " and upper(a.nombre) like '%"+request.getParameter("descripcion").toUpperCase()+"%'";
    descripcion = request.getParameter("descripcion");
  }

	if (fp.equalsIgnoreCase("med") )//med = Hoja de Medicamentos.
	{
  sql = " select a.codigo_orden_med orden_med, a.via, a.frecuencia, a.concentracion, a.dosis, a.nombre, a.observacion,b.descripcion as descVia,a.dosis_desc as dosisDesc, a.cantidad, a.tipo_orden, (select '<b>ACCION:</b> '|| m.accion||'<br><b>INTERACCION:</b>'||m.interaccion from tbl_sal_medicamentos m where m.compania = "+((String) session.getAttribute("_companyId"))+" and m.status = 'A' and antibio_ctrl = 'S' and m.medicamento = substr(a.nombre,0, instr(a.nombre,'/')-2 )and a.tipo_orden = 2 and rownum = 1) control from tbl_sal_detalle_orden_med a,tbl_sal_via_admin b where a.via=b.codigo(+) and  a.tipo_orden = 2 and  a.omitir_orden='N' and a.estado_orden = 'A' and a.pac_id = "+pacId+"  and a.secuencia = "+noAdmision+" "+appendFilter+" order by nombre";
		al = SQLMgr.getDataList("select * from (select rownum as rn, a.* from ("+sql+") a) where rn between "+previousVal+" and "+nextVal);
		rowCount = CmnMgr.getCount("select count(*) from ( "+sql+")");
	}

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
  
  System.out.println("*********************************************************************************************");
  System.out.println(sql);
  System.out.println("*********************************************************************************************");
%>
<html>
<head>
<%@ include file="../common/nocache.jsp"%>
<%@ include file="../common/header_param.jsp"%>
<script language="javascript">
document.title = 'Medicamentos - '+document.title;

/*Verifica si el medicamento controlado tiene mas de 7 días 
*param: fo fechaOrden
*return boolean
*/
function isValidDate(fo){
    var valor = getDBData("<%=request.getContextPath()%>","case when to_date('"+fo+"','dd/mm/yyyy') + 7 /*f_tope*/ <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') then 'NO' else 'YES' end validacion","dual");
	//alert(fo +"  "+valor);
	return (valor=='YES'?true:false);
}

/*Manda un mensaje si el medicamento esta controlado
*y la fecha de la orden tiene mas de 7 días
*param: fo fechaOrden
*return void
*/
function avisar(index,flag){
var fp = "<%=fp%>";
if (fp == "med"){
	 var checkAll = document.getElementById("check");
	 var counter = 0;
	if ( index == null || flag == null ){
		 if ( checkAll.checked == true ){
			for ( i = 0; i<<%=al.size()%>; i++ ){
				var medName = document.getElementById("medicamento"+i).value;
				var fechaOrden = document.getElementById("fechaOrden"+i).value;
				if ( getCtrlMedicamento(medName) != "" && !isValidDate(fechaOrden) ){
				    counter++;
				}
			} // for i
			if (counter > 0) alert("Su selección contiene medicamento"+(counter>1?'s':'')+" controlado"+(counter>1?'s':'')+" y la fecha de orden tiene mas de 7 días, creemos que debería consultar con un infectológo!");
		 }
    }else{
		var totMedicamento = <%=al.size()%>;
		var medName = document.getElementById("medicamento"+index).value;
		var fechaOrden = document.getElementById("fechaOrden"+index).value;
		var medicamento =  "";
		if ( flag.checked == true ) medicamento = getCtrlMedicamento (medName);
		if ( flag.checked == true && medicamento != "" && !isValidDate(fechaOrden) ){
			alert("PRECAUCION: Medicamento controlado: << "+medicamento+" >>, la orden médica fue colocada el día "+fechaOrden+", hace más de 7 días. Ningun paciente debe tomar medicamentos controlados por más de 7 días, se debe consultar al INFECTOLOGO!");
		}
    }//no esta seleccionado todo en un golpe
} // para poder usarla sin parámetros
}

function getCtrlMedicamento(med){
    var medicamento = getDBData("<%=request.getContextPath()%>","medicamento","tbl_sal_medicamentos", "status = 'A' and antibio_ctrl = 'S' and medicamento = nvl(trim(substr('"+med.trim()+"',1, instr('"+med.trim()+"','/',1)-1)),trim('"+med.trim()+"'))/*and medicamento= '"+med.trim()+"'*/");
	return medicamento;
}

function printOrden(noOrden){
  abrir_ventana('../expediente/print_exp_seccion_5.jsp?fg=CS&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&noOrden='+noOrden+'&desc=O/M MEDICAMENTOS&from=<%=from%>');
}

$(function(){
  $(".control-launcher").tooltip({
	content: function () {
	  var $i = $(this).data("i");
	  var $title = $($(this).prop('title'));
	  var $content = $("#controlCont"+$i).val();
	  var $cleanContent = $($content).text();
	  if (!$cleanContent) $content = "";
	  return $content;
	}
  });
});
</script>
</head>
<body topmargin="0" leftmargin="0" rightmargin="0">
<jsp:include page="../common/title.jsp" flush="true">
	<jsp:param name="title" value="SELECCION DE MEDICAMENTOS"></jsp:param>
</jsp:include>
<table align="center" width="99%" cellpadding="1" cellspacing="0">
	<tr>
		<td align="right">&nbsp;</td>
	</tr>
	<tr>
		<td>

<!-- ================================   S E A R C H   E N G I N E S   S T A R T   H E R E   ================================ -->

			<table width="100%" cellpadding="1" cellspacing="0">
			<tr class="TextFilter">
<%
fb = new FormBean("search01",request.getContextPath()+request.getServletPath());
%>
				<%=fb.formStart()%>
				<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
				<%=fb.hidden("fp",fp)%>
				<%=fb.hidden("mode",mode)%>
				<%=fb.hidden("pacId",pacId)%>
				<%=fb.hidden("noAdmision",noAdmision)%>
				<%=fb.hidden("lastLineNo",""+lastLineNo  )%>
				<%=fb.hidden("seccion",""+seccion)%>
				<%=fb.hidden("from", from)%>
				<%=fb.hidden("cds", cds)%>
				<td width="50%">
					<cellbytelabel>Descripci&oacute;n</cellbytelabel>
					<%=fb.textBox("descripcion","",false,false,false,40)%>
					<%=fb.submit("go","Ir")%>
				</td>
				<%=fb.formEnd()%>
			</tr>
			
			<%if(!cdoParam.getColValue("mostrar_med_en_hoja_med","N").equalsIgnoreCase("Y") || cdoParam.getColValue("mostrar_med_en_hoja_med","N").equalsIgnoreCase("S")){%>
			<tr>
        <td>
            <iframe src="../expediente/hoja_medicamento_list.jsp?pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&fp=<%=fp%>" style="height:150px; width:100%; border:0px;"></iframe>
        </td>
      </tr>
      <%}%>
			
			
			</table>

<!-- ================================   S E A R C H   E N G I N E S   E N D   H E R E   ================================ -->

		</td>
	</tr>
  <tr>
    <td align="right">&nbsp;</td>
  </tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
<%
fb = new FormBean("medicamentos",request.getContextPath()+request.getServletPath(),FormBean.POST);
%>
<%=fb.formStart(true)%>
<%=fb.hidden("fromPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("toPage",request.getContextPath()+request.getServletPath())%>
<%=fb.hidden("nextValP",""+(nxtVal-recsPerPage))%>
<%=fb.hidden("previousValP",""+(preVal-recsPerPage))%>
<%=fb.hidden("nextValN",""+(nxtVal+recsPerPage))%>
<%=fb.hidden("previousValN",""+(preVal+recsPerPage))%>
<%=fb.hidden("searchOn",searchOn)%>
<%=fb.hidden("searchVal",searchVal)%>
<%=fb.hidden("searchValFromDate",searchValFromDate)%>
<%=fb.hidden("searchValToDate",searchValToDate)%>
<%=fb.hidden("searchType",searchType)%>
<%=fb.hidden("searchDisp",searchDisp)%>
<%=fb.hidden("searchQuery","sQ")%>
<%=fb.hidden("size",""+al.size())%>
<%=fb.hidden("fp",fp)%>
<%=fb.hidden("mode",mode)%>
<%=fb.hidden("pacId",pacId)%>
<%=fb.hidden("noAdmision",noAdmision)%>
<%=fb.hidden("lastLineNo",""+lastLineNo  )%>
<%=fb.hidden("seccion",""+seccion)%>
<%=fb.hidden("from", from)%>
<%=fb.hidden("cds", cds)%>
	<tr>
		<td class="TableLeftBorder TableTopBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousT","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextT","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<table width="99%" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td class="TableLeftBorder TableRightBorder">

	<!-- ================================   R E S U L T S   S T A R T   H E R E   ================================ -->

			<table align="center" width="100%" cellpadding="0" cellspacing="1">
				<tr class="TextHeader" align="center">
					<td width="3%">#Ord.</td>
					<td width="25%"><cellbytelabel>Medicamentos</cellbytelabel></td>
					<td width="8%"><cellbytelabel>Concentr</cellbytelabel>.</td>
					<td width="8%"><cellbytelabel>Dosis<%=from.equalsIgnoreCase("exp3")?" Desc.":""%></cellbytelabel></td>
					<td width="15%"><cellbytelabel>Via</cellbytelabel> </td>
					<td width="19%"><cellbytelabel>Frecuencia</cellbytelabel></td>
					<td width="19%"><cellbytelabel>Observaci&oacute;n</cellbytelabel></td>

					<td width="3%"><%=fb.checkbox("check","",false,false,null,null,"onClick=\"javascript:checkAll('"+fb.getFormName()+"','check',"+al.size()+",this); avisar();\"","Seleccionar todos los Medicamentos listados!")%></td>
				</tr>
<%
String dieta ="";
for (int i=0; i<al.size(); i++)
{
	CommonDataObject cdo = (CommonDataObject) al.get(i);
	String color = "TextRow02";
	if (i % 2 == 0) color = "TextRow01";
%>
				<%=fb.hidden("medicamento"+i,cdo.getColValue("nombre"))%>
				<%=fb.hidden("dosis"+i,cdo.getColValue("dosis"))%>
				<%=fb.hidden("frecuencia"+i,cdo.getColValue("frecuencia"))%>
				<%=fb.hidden("via"+i,cdo.getColValue("via"))%>
				<%=fb.hidden("observacion"+i,cdo.getColValue("observacion"))%>
				<%=fb.hidden("dosisDesc"+i,cdo.getColValue("dosisDesc"))%>
				<%=fb.hidden("cantidad"+i,cdo.getColValue("cantidad"))%>
				<%=fb.hidden("controlCont"+i,"<label class='controlCont' style='font-size:11px'>"+(cdo.getColValue("control")==null?"":cdo.getColValue("control"))+"</label>")%>
				
				<%//=fb.hidden("concentracion"+i,cdo.getColValue("concentracion"))%>

				<tr class="<%=color%>" onMouseOver="setoverc(this,'TextRowOver')" onMouseOut="setoutc(this,'<%=color%>')">
					<td align="center">            
            <a href="javascript:printOrden(<%=cdo.getColValue("orden_med")%>)" class="LinksTextwhite" onMouseOver="setoverc(this,'LinksTextblack')" onMouseOut="setoutc(this,'LinksTextwhite')"><font class="Link06"><%=cdo.getColValue("orden_med")%></font></a>
          </td>
					<td><%=cdo.getColValue("nombre")%>
                    <%if(!cdo.getColValue("cantidad"," ").trim().equals("")){%>
                    &nbsp;<b>##<%=cdo.getColValue("cantidad")%></b>
                    <%}%>
					
					<img src="../images/info.png" width="24px" height="24px" class="control-launcher" title="" data-i="<%=i%>" style="vertical-align:middle">
					
                    </td>
					<td><%=cdo.getColValue("concentracion")%></td>
					<td><%=from.equalsIgnoreCase("exp3")?cdo.getColValue("dosisDesc"):cdo.getColValue("dosis")%></td>
					<td><%=cdo.getColValue("descVia")%></td>
					<td><%=cdo.getColValue("frecuencia")%></td>
					<td><%=cdo.getColValue("observacion")%></td>
					<td align="center"><%=((fp.equalsIgnoreCase("med") && vMed.contains(cdo.getColValue("nombre"))))?"Elegido":fb.checkbox("check"+i,cdo.getColValue("medicamento"),false,false,null, null,"onClick=\"avisar("+i+",this)\"")%></td>
				</tr>
<%
}
%>
			</table>

<!-- ================================   R E S U L T S   E N D   H E R E   ================================ -->

		</td>
	</tr>
</table>

<table align="center" width="99%" cellpadding="0" cellspacing="0">
	<tr>
		<td class="TableLeftBorder TableRightBorder">
			<table align="center" width="100%" cellpadding="1" cellspacing="0">
				<tr class="TextPager">
					<td width="10%"><%=(preVal != 1)?fb.submit("previousB","<<-"):""%></td>
					<td width="40%"><cellbytelabel>Total Registro(s)</cellbytelabel> <%=rowCount%></td>
					<td width="40%" align="right"><cellbytelabel>Registros desde</cellbytelabel> <%=pVal%> <cellbytelabel>hasta</cellbytelabel> <%=nVal%></td>
					<td width="10%" align="right"><%=(!(rowCount <= nxtVal))?fb.submit("nextB","->>"):""%></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="TableLeftBorder TableBottomBorder TableRightBorder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr class="TextPager">
					<td align="right">
						<%=fb.submit("save","Guardar",true,false)%>
						<%=fb.button("cancel","Cancelar",true,false,null,null,"onClick=\"javascript:window.close()\"")%>
					</td>
				</tr>
			</table>
		</td>
	</tr>
<%=fb.formEnd()%>
</table>

</body>
</html>
<%
}
else
{
	int size = Integer.parseInt(request.getParameter("size"));
	String cDateTime = CmnMgr.getCurrentDate("dd/mm/yyyy hh12:mi am");
	for (int i=0; i<size; i++)
	{
		if (request.getParameter("check"+i) != null)
		{
			 if (fp.equalsIgnoreCase("med"))
			{

				HojaMedicamentoDet det = new HojaMedicamentoDet();

				det.setMedicamento(request.getParameter("medicamento"+i));
				det.setDosis(request.getParameter("dosis"+i));
				det.setVia(request.getParameter("via"+i));
				//det.setDescripcion(request.getParameter("descDo"+i));
				det.setCantidad(request.getParameter("cantidad"+i));
				det.setFrecuencia(request.getParameter("frecuencia"+i));
				if(from.equalsIgnoreCase("exp3"))det.setDosisDesc(request.getParameter("dosisDesc"+i));
				//det.setObservacion(request.getParameter("observacion"+i));
				det.setHora(cDateTime.substring(11));
				lastLineNo++;

				String key = "";
				if (lastLineNo < 10) key = "00"+lastLineNo;
				else if (lastLineNo < 100) key = "0"+lastLineNo;
				else key = ""+lastLineNo;
				det.setKey(""+key);

				try
				{
					vMed.add(det.getMedicamento());
					HashMed.put(key,det);
				}
				catch(Exception e)
				{
					System.err.println(e.getMessage());
				}

			}
		}// checked
	}

	if (request.getParameter("previousT") != null || request.getParameter("previousB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&seccion="+seccion+"&noAdmision="+noAdmision+"&lastLineNo="+lastLineNo+"&nextVal="+request.getParameter("nextValP")+"&previousVal="+request.getParameter("previousValP")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&from="+request.getParameter("from")+"&cds="+request.getParameter("cds"));
		return;
	}


	else if(request.getParameter("nextT") != null || request.getParameter("nextB") != null)
	{
		response.sendRedirect(request.getContextPath()+request.getServletPath()+"?fp="+fp+"&mode="+mode+"&pacId="+pacId+"&seccion="+seccion+"&noAdmision="+noAdmision+"&lastLineNo="+lastLineNo+"&nextVal="+request.getParameter("nextValN")+"&previousVal="+request.getParameter("previousValN")+"&searchOn="+request.getParameter("searchOn")+"&searchVal="+request.getParameter("searchVal")+"&searchValFromDate="+request.getParameter("searchValFromDate")+"&searchValToDate="+request.getParameter("searchValToDate")+"&searchType="+request.getParameter("searchType")+"&searchDisp="+request.getParameter("searchDisp")+"&searchQuery="+request.getParameter("searchQuery")+"&from="+request.getParameter("from")+"&cds="+request.getParameter("cds"));
		return;
	}

%>
<html>
<head>
<script>
function closeWindow()
{
<%
	if (fp.equalsIgnoreCase("med"))
	{
%>
	window.opener.location = '../expediente<%=from.equalsIgnoreCase("exp3")?"3.0":""%>/exp_hoja_medicamento_det.jsp?change=1&mode=<%=mode%>&pacId=<%=pacId%>&noAdmision=<%=noAdmision%>&lastLineNo=<%=lastLineNo%>&seccion=<%=seccion%>&cds=<%=cds%>';

<%}%>

	window.close();
}
</script>
</head>
<body onLoad="javascript:closeWindow()">
</body>
</html>
<%
}
%>