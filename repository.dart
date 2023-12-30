
import 'package:anytime/entities/episode.dart';
import 'package:anytime/entities/podcast.dart';
import 'package:anytime/entities/transcript.dart';
import 'package:anytime/state/episode_state.dart';


abstract class Repository {
  Future<void> close();

  Future<Podcast?> findPodcastById(num id);

  Future<Podcast?> findPodcastByGuid(String guid);

  Future<Podcast> savePodcast(Podcast podcast);

  Future<void> deletePodcast(Podcast podcast);

  Future<List<Podcast>> subscriptions();

  /// Episodes
  Future<List<Episode>> findAllEpisodes();

  Future<Episode?> findEpisodeById(int id);

  Future<Episode?> findEpisodeByGuid(String guid);

  Future<List<Episode?>> findEpisodesByPodcastGuid(String pguid);

  Future<Episode?> findEpisodeByTaskId(String taskId);

  Future<Episode> saveEpisode(Episode episode, [bool updateIfSame = false]);

  Future<void> deleteEpisode(Episode episode);

  Future<void> deleteEpisodes(List<Episode> episodes);

  Future<List<Episode>> findDownloadsByPodcastGuid(String pguid);

  Future<List<Episode>> findDownloads();

  Future<Transcript?> findTranscriptById(int id);

  Future<Transcript> saveTranscript(Transcript transcript);

  Future<void> deleteTranscriptById(int id);

  Future<void> deleteTranscriptsById(List<int> id);

  /// Queue
  Future<void> saveQueue(List<Episode> episodes);

  Future<List<Episode>> loadQueue();

  /// Event listeners
  Stream<Podcast>? podcastListener;
  Stream<EpisodeState>? episodeListener;
}
