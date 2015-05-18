import gate.mimir.web.Index;
import gate.mimir.web.IndexTemplate;
import gate.mimir.web.LocalIndex;
import gate.mimir.web.MimirConfiguration
import gate.mimir.web.LocalIndexService

class FIBootStrap {
    
    long indexId = 1
    long indexTemplateId = 1
    def name = 'typo3'
    
    def init = { servletContext ->
        LocalIndex theIndex = LocalIndex.get(indexId)
        if (theIndex) {
            println "found forgetindex"
            return
        }
        
        IndexTemplate indexTemplateInstance = IndexTemplate.get(indexTemplateId)
        if (!indexTemplateInstance) {
            println "Index template not found with ID ${indexTemplateId}"
            return
        }
    
        LocalIndex localIndexInstance = new LocalIndex(indexId:indexId)
        localIndexInstance.name = name
        localIndexInstance.uriIsExternalLink = true
        localIndexInstance.state = Index.READY
        try {
            def mimirConfigurationInstance = MimirConfiguration.findByIndexBaseDirectoryIsNotNull()
            if (!mimirConfigurationInstance) {
                println "No instance of ${MimirConfiguration.class.name} could be found!"    
                return
            }
      
            def tempFile = File.createTempFile('index-', '.mimir',new File(mimirConfigurationInstance.indexBaseDirectory))
            tempFile.delete()
            localIndexInstance.indexDirectory = tempFile.absolutePath
        } catch (IOException e) {
            println "Couldn't create directory for new index"
            return
        }
    
        if(!localIndexInstance.hasErrors() && localIndexInstance.save()) {
            try {
                (new LocalIndexService()).createIndex(localIndexInstance, indexTemplateInstance)
                println "LocalIndex \"${localIndexInstance.name}\" created"
                return
            } catch (Exception e) {
                println "Could not create local index. Problem was: \"${e.message}\"."
                localIndexInstance.delete()
                return
            }
        }
    }
}