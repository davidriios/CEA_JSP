<%@ page import="issi.admin.CommonDataObject"%>
<%
issi.admin.ConnectionMgr ConMgr = new issi.admin.ConnectionMgr();
issi.admin.SQLMgr SQLMgr = new issi.admin.SQLMgr();
String pacId=request.getParameter("pacId")==null?"":request.getParameter("pacId");
String seccionId=request.getParameter("seccionId")==null?"":request.getParameter("seccionId");
String noAdmision=request.getParameter("admision")==null?"":request.getParameter("admision");
String widgetOpenClose = request.getParameter("widgetOpenClose")==null?"":request.getParameter("widgetOpenClose");//"widget-closed";
String colSpanClass=request.getParameter("colSpanClass")==null?"col-md-6":request.getParameter("colSpanClass");
		
String fp=request.getParameter("fp")==null?"":request.getParameter("fp");
SQLMgr.setConnection(ConMgr);
java.util.ArrayList al = SQLMgr.getDataList("select r.seccion_desc, r.documento_id, r.tipo, r.documento_id||'@@'||r.seccion_id as doc_sec_id, seccion_tabla, seccion_columnas, seccion_where_clause, ultimos_n_registros, ultimos_x_registros, seccion_order_by from tbl_sal_secciones_resumen r where r.estado = 'A' and r.seccion_id="+seccionId+" order by orden");

if(al.size()==0) return;
%>

	<%  for (int i = 1; i<=al.size();i++){
			CommonDataObject cdo = (CommonDataObject)al.get(i-1);
			StringBuffer sbSql=new StringBuffer();
			
			String dateField = "",_where=(cdo.getColValue("seccion_where_clause")).replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision), xtraWhere = "";
			String[] limit={};
			String columns = (cdo.getColValue("seccion_columnas", " ")).replaceAll("@@PACID",pacId).replaceAll("@@ADMISION",noAdmision);
			
			
			if ((cdo.getColValue("seccion_where_clause")).contains("DATE_FIELD")){
				limit = (cdo.getColValue("ultimos_x_registros")).split(" ");
				String limitType = limit[1];
				dateField = _where.substring( _where.lastIndexOf("-")+1,_where.length() );
				//_where = _where.replaceAll("@@DATE_FIELD-"+dateField," and "+dateField);
				_where = _where.replaceAll("@@DATE_FIELD-"+dateField," ");
				
				if (limitType.equalsIgnoreCase("d")){
				   _where += " and trunc("+dateField+")>=sysdate-"+limit[0];
				}else {
				   String _interval = limitType.equalsIgnoreCase("m")?"minute":"hour";
				   _where += " and "+dateField+" >= sysdate-(interval '"+limit[0]+"' "+_interval+")";
				}
			}
			
			if (cdo.getColValue("ultimos_n_registros")!=null&&!cdo.getColValue("ultimos_n_registros").trim().equals("")){
			  _where += " and rownum <= nvl("+cdo.getColValue("ultimos_n_registros")+",0)";
			}else if (cdo.getColValue("ultimos_x_registros")!=null&&!cdo.getColValue("ultimos_x_registros").trim().equals("")){}
			
			if (!columns.contains("READY")){
			System.out.println(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: NO READY");
			System.out.println(columns);
			sbSql.append("select ");
			sbSql.append(columns);
			sbSql.append(" from ");
			sbSql.append(cdo.getColValue("seccion_tabla"));
			sbSql.append(" where ");
			
			sbSql.append(_where);
			if (cdo.getColValue("seccion_order_by")!=null && !cdo.getColValue("seccion_order_by").trim().equals("")) 
				sbSql.append(" order by "+cdo.getColValue("seccion_order_by"));
		  }else{
			sbSql = new StringBuffer();
		    sbSql.append("select * from(");
			sbSql.append(columns.replaceAll("READY@@","").replaceAll("@@XTRA_WHERE"," and "+_where));
			sbSql.append(" ) ");
		  }
		  
		  try{
		  java.util.ArrayList alD = new java.util.ArrayList();
			if (!columns.equalsIgnoreCase("remote"))
				 alD= SQLMgr.getDataList(sbSql.toString());
		  String res = "";
		  for (int d=0;d<alD.size();d++){
			CommonDataObject cdoD = (CommonDataObject) alD.get(d);	
			
		    String showMore = "";
			if(cdo.getColValue("tipo").equals("P")){
			   if ( (d+1) == alD.size() ) showMore = " <span class='Link00Bold pointer show-more' id='show-more-"+seccionId+"-"+i+"' data-i='"+i+"' data-docsec='"+cdo.getColValue("doc_sec_id")+"'>[+]</span>";
			   res += "<li>"+cdoD.getColValue("col_val")+showMore+"</li>";
			}else{
			   res += cdoD.getColValue("col_val")+"~";
			}
		  }
		   

		%>
		
<div class="<%=colSpanClass%>" id="condactual-<%=seccionId%>-container">

					<div class="widget box <%=widgetOpenClose%>">
							<div class="widget-header">
								<h4 class="section pointer" data-i="<%=i%>" data-tipo="<%=cdo.getColValue("tipo")%>" data-remote="<%=cdo.getColValue("seccion_columnas").equalsIgnoreCase("remote")%>"><i class="icon-reorder"></i><%=cdo.getColValue("seccion_desc")%> <span class="label label-danger"><%=alD.size()%></span></h4>
								<div class="toolbar no-padding">
									<div class="btn-group">
										<span class="btn btn-xs widget-collapse" id="expander-condactual<%=seccionId%>"><i class="icon-angle-up"></i></span>
										<%if(!seccionId.equals("77")){%>
										<span class="btn btn-xs widget-refresh refresh-it" data-url="../datawidgets/cond_actual_paciente.jsp?pacId=<%=pacId%>&admision=<%=noAdmision%>&seccionId=<%=seccionId%>" data-container="#condactual-<%=seccionId%>-container" data-expander="#condactual<%=seccionId%>" data-remotepath="<%=cdo.getColValue("seccion_columnas", " ").equalsIgnoreCase("remote") ? cdo.getColValue("seccion_where_clause") : ""%>" data-i="<%=i%>" data-remote="<%=cdo.getColValue("seccion_columnas", " ").equalsIgnoreCase("remote") ? cdo.getColValue("seccion_columnas") : ""%>" data-horario="<%=cdo.getColValue("ultimos_x_registros")%>" data-seccionid="<%=seccionId%>">
											<i class="icon-refresh"></i>
										</span>
										<%}%>
									</div>
								</div>
							</div>
							<div class="widget-content no-padding">
							<div class="table-responsive">
		<br />				
		<%if(cdo.getColValue("tipo").equals("P")){%>
			<ul id="plain-text-<%=seccionId%>-<%=i%>" class="plain-text"><%=res%></ul>
		<%}else if(cdo.getColValue("seccion_columnas").equalsIgnoreCase("remote")){%>
			<div style="text-align:center" id="remote-container-<%=seccionId%>-<%=i%>">
			<img src="" class="remote" id="remote-<%=seccionId%>-<%=i%>" title="<%=cdo.getColValue("seccion_desc")%>" data-i="<%=i%>" data-remotepath="<%=cdo.getColValue("seccion_where_clause")%>" data-horario="<%=cdo.getColValue("ultimos_x_registros")%>" data-seccionid="<%=seccionId%>"/>
			</div>
		<%}else{%>
		<span class="cData" id="cData<%=i%>" data-i="<%=i%>" style="display:none"><%=res%></span>
		<table border="1" width="100%" id="chart-container-<%=i%>" class="chart-container">
			<tr>
				<td align="center"><canvas id="chartT-<%=i%>" width="600" height="300" style=""></canvas></td>
				<td align="center"><canvas id="chartP-<%=i%>" width="600" height="300" style=""></canvas></td>
		    </tr>
			<tr>
				<td align="center"><canvas id="chartR-<%=i%>" width="600" height="300" style=""></canvas></td>
				<td align="center"><canvas id="chartPA-<%=i%>" width="600" height="300" style=""></canvas></td>
		    </tr>
			<tr>
				<td align="center" colspan="2"><canvas id="chartSO-<%=i%>" width="1200" height="300" style=""></canvas></td>
			</tr>
		</table>
		<%}%>
<%
}catch(Exception e){System.out.println(":::::::::::::::::::::::::::::::: Error while "+e);e.printStackTrace();}
}%>
</div>
								
							</div> <!-- /.widget-content -->
						</div> <!-- /.widget -->
			</div> <!-- /.col-md-6 -->
					<!-- /Static Table -->
				