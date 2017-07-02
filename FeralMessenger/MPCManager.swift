//
//  MPCManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/7/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import MultipeerConnectivity


// MARK: - MPCManagerDelegate

protocol MPCManagerDelegate {
    func foundPeer()
    func lostPeer()
    func didReceivedInvitation(fromPeer: String, group: String)
    func didConnect(fromPeer: MCPeerID, group: String)
    func didStartAdvertising()
    func didStopAdvertising()
}

extension MPCManagerDelegate {
    func foundPeer() {}
    func lostPeer() {}
    func didReceivedInvitation(fromPeer: String, group: String) {}
    func didConnect(fromPeer: MCPeerID, group: String) {}
    func didStartAdvertising() {}
    func didStopAdvertising() {}
}


/// Implement this class on AppDelegate
class MPCManager: NSObject {
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    var serviceType = "feral-mpc" // must be all lowercased and shorter than 15 chars!!!
    var serviceBrowser: MCNearbyServiceBrowser
    var serviceAdvertiser: MCNearbyServiceAdvertiser
    
    var session: MCSession!
    var group: String!
    
    var initationHandler: ((Bool, MCSession?) -> Void)!
    var invitationHandler: ((Bool, MCSession?) -> Void)!
    
    var delegate: MPCManagerDelegate?
    
    var foundPeers = [MCPeerID]()
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        do {
            try session.send(dataToSend, toPeers: [targetPeer], with: MCSessionSendDataMode.reliable)
            return true
        } catch let err {
            print(err.localizedDescription)
            return false
        }
    }
    
    func startAdvertise() {
        serviceAdvertiser.startAdvertisingPeer()
        delegate?.didStartAdvertising()
    }
    
    func stopAdvertise() {
        serviceAdvertiser.stopAdvertisingPeer()
        delegate?.didStopAdvertising()
    }
    
    override init() {
        // session must be the first one to be initialized
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        super.init()
        self.session.delegate = self
        self.serviceBrowser.delegate = self
        self.serviceAdvertiser.delegate = self
        group = "new group"
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
}


// MARK: - MCSessionDelegate

extension MPCManager: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let dictionary: [String : AnyObject] = ["data" : data as AnyObject, "fromPeer" : peerID]
        NotificationCenter.default.post(name: NSNotification.Name("receivedMPCDataNotification"), object: dictionary)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            delegate?.didConnect(fromPeer: peerID, group: "")
            print("Connected to session: \(session)")
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
        default:
            print("Did not connect to session \(session)")
        }
    }
    
    // if didReceiveCertificate is not defined. Then it will accept any certificate, otherwise it must be handled
    
}


// MARK: - MCNearbyServiceBrowserDelegate

extension MPCManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        delegate?.foundPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerated() {
            if aPeer == peerID {
                foundPeers.remove(at: index)
                break
            }
        }
        delegate?.lostPeer()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print(error.localizedDescription)
    }
    
}


// MARK: - MCNearbyServiceAdvertiserDelegate

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        self.invitationHandler = invitationHandler
        delegate?.didReceivedInvitation(fromPeer: peerID.displayName, group: group)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print(error.localizedDescription)
    }
    
}


























