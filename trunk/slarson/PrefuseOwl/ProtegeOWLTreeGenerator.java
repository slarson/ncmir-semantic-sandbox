


import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.PrintStream;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Stack;

import javax.swing.JTree;
import javax.swing.tree.TreeModel;

import com.hp.hpl.jena.util.FileUtils;

import prefuse.data.Graph;
import prefuse.data.Node;
import prefuse.data.Tree;
import prefuse.data.io.DataIOException;
import prefuse.data.io.GraphMLWriter;
import prefuse.data.io.TreeMLWriter;
import edu.stanford.smi.protege.model.Cls;
import edu.stanford.smi.protege.model.Project;
import edu.stanford.smi.protege.model.Slot;
import edu.stanford.smi.protege.ui.ProjectManager;
import edu.stanford.smi.protege.util.ApplicationProperties;
import edu.stanford.smi.protegex.owl.ProtegeOWL;
import edu.stanford.smi.protegex.owl.jena.JenaOWLModel;
import edu.stanford.smi.protegex.owl.repository.RepositoryManager;
import edu.stanford.smi.protegex.owl.repository.impl.LocalFolderRepository;
import edu.stanford.smi.protegex.owl.ui.subsumption.AssertedSubsumptionTreePanel;
import edu.stanford.smi.protegex.owl.ui.subsumption.SubsumptionTreeNode;
import edu.stanford.smi.protegex.owl.ui.subsumption.SubsumptionTreeRoot;



public class ProtegeOWLTreeGenerator {
	
    Tree g;
    HashMap<String,Cls> hm;
    String label, prefix;
	Slot rdfsLabel;
    public ProtegeOWLTreeGenerator() {
    	g = new Tree();
    	g.addColumn("label", String.class);
    	
		//g.addColumn("owlClass", Cls.class);
    	hm = new HashMap<String,Cls>();
    }
    
    public void createOWLGraph() {
            
        	loadOntology();
            
        	/*
            Node root = this.getGraph().addNode();
            root.set("label", "root");
            for (Iterator it = this.getGraph().nodes(); it.hasNext();) {
            	Node n = (Node)it.next();
            	if (this.getGraph().getInDegree(n) < 1) {
            		if (!"root".equals(n.get("label"))) {
            			this.getGraph().addEdge(root, n);
            		}
            	}
            }*/
        	
        	System.out.println(g.isValidTree());

    }
    
    private void loadOntology() {
    	try {

    		//JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModelFromURI("http://ccdb.ucsd.edu/SAO/1.2.9/SAO.owl");
    		
    		
    		ApplicationProperties.setUrlConnectTimeout(100000);
			ApplicationProperties.setUrlConnectReadTimeout(100000);
			System.getProperties().put("proxySet", "true");
			System.getProperties().put("proxyPort", "8080");
			System.getProperties().put("proxyHost", "http://webproxy.ucsd.edu/proxy.pl");
			//JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModelFromURI("http://purl.org/nbirn/birnlex/ontology/BIRNLex-Anatomy.owl");
    		//JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModelFromURI("http://purl.org/nif/ontology/nif.owl");
			
			//ProjectManager projectManager = ProjectManager.getProjectManager();
			//URI uri = new URI("file://C:\/Documents\and\ Settings\/stephen\/Desktop\/nifSaved\/nif.pprj");
						
			Project p = Project.loadProjectFromFile("C:/Documents and Settings/stephen/Desktop/nifSaved/nif.pprj", new ArrayList());
						
			//projectManager.loadProject(uri);
			JenaOWLModel owlModel = (JenaOWLModel) p.getKnowledgeBase();
					    			
			/*
			JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModel();
			RepositoryManager rp = new RepositoryManager(owlModel);
			File dir = new File("C:/Documents and Settings/stephen/Desktop/nifSaved");
			rp.addGlobalRepository(new LocalFolderRepository(dir));
			FileReader reader = new FileReader("C:/Documents and Settings/stephen/Desktop/nifSaved/nif.owl");			
			owlModel.load(reader, FileUtils.langXMLAbbrev);
    		*/
    		
    		//must be done before getLabel() is run!!!
    		rdfsLabel = owlModel.getSlot("rdfs:label");
    		
    		if (owlModel != null) {

    			Cls root = owlModel.getRootCls();
    			Cls entity = owlModel.getCls("bfo:Entity");
    			System.out.println("The root class is: " + entity.getName());
    			Node rootNode = getTree().addRoot();
    			Slot rdfsLabel = owlModel.getSlot("rdfs:label");
    			String label = (String)entity.getDirectOwnSlotValue(rdfsLabel);
    			String prefix = owlModel.getPrefixForResourceName(entity.getName());
    			if (prefix != null) {
    				label =  prefix + ":" + label;
    			}
    			rootNode.setString("label", label);
    			hm.put(label, entity);
    			//rootNode.set("owlClass", entity);

    			//loadClassIntoTree(rootNode, owlModel);
    			
    			FileOutputStream file2 = null;
    			try {
    				file2 = new FileOutputStream("SAO-tree.xml");
    			} catch (FileNotFoundException e) {
    				// TODO Auto-generated catch block
    				e.printStackTrace();
    			}
    	    	
    	    	PrintStream s = new PrintStream(file2);
    	    	s.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    	    	s.println("<tree>");
    	    	//s.println("<!DOCTYPE tree SYSTEM \"treeml.dtd\"><!DOCTYPE tree SYSTEM \"treeml.dtd\">");
    	    	s.println("<declarations><attributeDecl name=\"label\" type=\"String\"/></declarations>");
    	    	
    	    	//loadClassIntoTreeML(rootNode, owlModel, s);
    	    	loadClassIntoTreeMLWithGUI(owlModel, s);

    		}
    	} catch (Exception e) {
    		e.printStackTrace();
    	}	
    }
    
    private void loadClassIntoTree(Node parent, JenaOWLModel owlModel) {
    	Slot rdfsLabel = owlModel.getSlot("rdfs:label");
    	LinkedList<Node> q = new LinkedList<Node>();
    	q.add(parent);
    	Node n;
    	Cls cls, xx;
    	String label2, prefix2;
    	Node child;
    	String owlClass = "owlClass";
    	String label = "label";
    	while (q.size() > 0) {
    		n = q.poll();
    		//cls = (Cls)n.get(owlClass);
    		cls = hm.get(n.getString(label));
    		//visit node
    		for (Object x : cls.getDirectSubclasses()) {
        		xx = (Cls) x;
        		if (!xx.isClsMetaCls() && !xx.isSystem() && xx.isVisible()) { 
        			
        			label2 = (String)xx.getDirectOwnSlotValue(rdfsLabel);
        			prefix2 = owlModel.getPrefixForResourceName(xx.getName());
        			if (prefix2 != null) {
        				label2 =  prefix2 + ":" + label2;
        			}
        			child = getTree().addChild(n);
        			child.setString(label, label2);
        			hm.put(label2, xx);
        			//child.set(owlClass, xx);
        			q.add(child);
        		}
        	}
    		//end visit
    	}
    	FileOutputStream file = null;
    	FileOutputStream file2 = null;
		try {
			file = new FileOutputStream("SAO-graph.xml");
			file2 = new FileOutputStream("SAO-tree.xml");
			
			GraphMLWriter writer = new GraphMLWriter();
			TreeMLWriter writer2 = new TreeMLWriter();
    	
			writer.writeGraph((Graph)g, file);
			writer2.writeGraph(g, file2);
    	} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (DataIOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	
    }
    
    
    /* Writes TreeML to disk as processing.
     * 
     * Builds up a stack, q, composed of arraylists, that themselves contain Cls's
     * The fact that Cls's are in LinkedLists allows the grouping of siblings and the 
     * correct placement of </branch> markers.
     */
    private void loadClassIntoTreeML(Node parent, JenaOWLModel owlModel, PrintStream s) {
    	
    	//the stack!
    	Stack<LinkedList<Cls>> q = new Stack<LinkedList<Cls>>();
    	//variables
    	Cls cls, xx;
    	//constants
    	HashSet<Cls> visitedList = new HashSet<Cls>();
    	
    	String label = "label";
    	String prefix = null;

    	//first iteration for parent
		cls = hm.get(parent.getString(label));
		LinkedList<Cls> a = new LinkedList<Cls>();
		a.add(cls);
		q.push(a);
		
		LinkedList<Cls> aa;

		//so long as the stack is not empty
		while (q.size() > 0) {
			//get a linked list
			LinkedList<Cls> a2 = q.pop();

			//get the first member and write some TreeML and add its subclasses to the stack
			Cls c = a2.poll();
			
			
			
			if (c == null || visitedList.contains(c)) {
				//if no subclasses, close off this branch
				continue;
			} else {
				visitedList.add(c);
				if (a2.size() > 0) {
					q.push(a2);
				}
			}
			
			Collection<Cls> subclasses = c.getDirectSubclasses();
			
			//how to get the label for this node
			label = (String)c.getDirectOwnSlotValue(rdfsLabel);
			prefix = owlModel.getPrefixForResourceName(c.getName());
			if (prefix != null) {
				label =  prefix + ":" + label;
			}

			//if there are no other subclasses, you are a leaf
			if (subclasses.size() < 1) {
				s.println("<leaf><attribute name=\"label\" value=\"" + label + "\"/></leaf>");

			} else {
				//there are subclasses, and you are a branch.
				//more leaves will fall under you.
				
				s.println("<branch><attribute name=\"label\" value=\"" + label + "\"/>");
				

				//add your subclasses to the stack so they can be processed next
				aa = new LinkedList<Cls>();
				for (Object x : subclasses) {
					xx = (Cls) x;
					
					if (!xx.isClsMetaCls() && !xx.isSystem() && xx.isVisible()) {
						aa.add(xx);
					}
					
				}
				q.push(aa);
			}
			if (a2.size() < 1) {
				s.println("</branch>");
			}
			s.flush();
		}
		s.println("</tree>");
    }
    
    /* Writes TreeML to disk as processing.
     * 
     * Builds up a stack, q, composed of arraylists, that themselves contain Cls's
     * The fact that Cls's are in LinkedLists allows the grouping of siblings and the 
     * correct placement of </branch> markers.
     */
    private void loadClassIntoTreeMLWithGUI(JenaOWLModel owlModel, PrintStream s) {
    	
    	//the stack!
    	Stack<SubsumptionTreeNode> q = new Stack<SubsumptionTreeNode>();
    	HashMap<SubsumptionTreeNode, LinkedList<SubsumptionTreeNode>> ancestorMap = new HashMap<SubsumptionTreeNode, LinkedList<SubsumptionTreeNode>>();
    	//variables
    	Cls cls, xx;
    	
    	AssertedSubsumptionTreePanel pane = new AssertedSubsumptionTreePanel(owlModel);
    	TreeModel m = pane.getClsesTree().getModel();
    	SubsumptionTreeRoot fakeRoot = (SubsumptionTreeRoot) m.getRoot();
    	SubsumptionTreeNode root = (SubsumptionTreeNode)fakeRoot.children().nextElement();
    	SubsumptionTreeNode entity = null;
    	Enumeration firstLevel = root.children();
    	while(firstLevel.hasMoreElements()) {
    		SubsumptionTreeNode next = (SubsumptionTreeNode)firstLevel.nextElement();
    		 //how to get the label for this node
			label = (String)next.getCls().getDirectOwnSlotValue(rdfsLabel);
			prefix = owlModel.getPrefixForResourceName(next.getCls().getName());
			if (prefix != null) {
				label =  prefix + ":" + label;
			}
			if ("bfo:entity".equals(label)) {
				entity = next;
			}
    	}
    	
    	if (entity == null) {
    		System.out.println("can't find bfo:entity!");
    		return;
    	}
    	
    	root = entity;
    	
    	String label = "label";
    	String prefix = null;

    	//first iteration for parent
		q.push(root);
		LinkedList<SubsumptionTreeNode> ancestorList = new LinkedList<SubsumptionTreeNode>();
		ancestorMap.put(root, ancestorList);
		
		//set to test ancestors
		HashSet<SubsumptionTreeNode> testSet = new HashSet<SubsumptionTreeNode>();
		
		//so long as the stack is not empty
		while (q.size() > 0) {
			//get a linked list
			SubsumptionTreeNode n = q.pop();
						
            //how to get the label for this node
			label = (String)n.getCls().getDirectOwnSlotValue(rdfsLabel);
			prefix = owlModel.getPrefixForResourceName(n.getCls().getName());
			if (prefix != null) {
				label =  prefix + ":" + label;
			}
			
			if (n.isLeaf()) {
				s.println("<leaf><attribute name=\"label\" value=\"" + label + "\"/></leaf>");	
			} else {
				s.println("<branch><attribute name=\"label\" value=\"" + label + "\"/>");
			}

			Enumeration subclasses = n.children();
			
			for(;subclasses.hasMoreElements();) {
				SubsumptionTreeNode next = (SubsumptionTreeNode)subclasses.nextElement();
				q.add(next);
				
				/* create ancestor list for this node */
				ancestorList = new LinkedList<SubsumptionTreeNode>();
				//my ancestors are my parents ancestors plus my parent.
				if (next.getParent() instanceof SubsumptionTreeNode) {
					SubsumptionTreeNode p = (SubsumptionTreeNode)next.getParent();
					ancestorList.addAll(ancestorMap.get(p));
					ancestorList.add(p);
				}
				/* add ancestor list to ancestorMap */
				ancestorMap.put(next, ancestorList);
				
			}
			s.flush();
			
			testSet.clear();
			//for all the nodes in the queue, add all their ancestors into testSet
			for (SubsumptionTreeNode t : q) {
				testSet.addAll(ancestorMap.get(t));
			}
			/* If I have a unique ancestors compared to the rest of the nodes
			 * left in the queue, then I need to be responsible
			 * for closing the branch for those ancestors
			 */
			for (SubsumptionTreeNode t : ancestorMap.get(n)) {
				if (!testSet.contains(t)) {
					s.println("</branch>");	
				}
			}
		}
		s.println("</tree>");
    }

    public Tree getTree() {
    	return g;
    }
   
    
    public static void main(String[] args) {
    	try {

    		JenaOWLModel owlModel = ProtegeOWL.createJenaOWLModelFromURI("http://ccdb.ucsd.edu/SAO/1.2.9/SAO.owl");

    		if (owlModel != null) {

    			Cls root = owlModel.getRootCls();
    			Cls entity = owlModel.getCls("bfo:Entity");
    			System.out.println("The root class is: " + entity.getName());
    			Slot rdfslabel = owlModel.getSlot("rdfs:label");

    			for (Object c : entity.getDirectSubclasses()) {
    				Cls cls = (Cls)c;

    				if (!cls.isClsMetaCls() && !cls.isSystem() && cls.isVisible()) {

    					System.out.println(cls.getDirectOwnSlotValue(rdfslabel));
    					System.out.println(owlModel.getPrefixForResourceName(cls.getName()));
    				}
    			}
    		}
    	} catch (Exception e) {
    		e.printStackTrace();
    	}
    }
}
